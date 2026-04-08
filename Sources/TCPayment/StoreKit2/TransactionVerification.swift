//
//  File.swift
//
//
//  Created by Ali on 06/09/2024.
//

import Foundation
import ParseCore
import TCPaymentValidation

enum Environment: String, Codable {
    case production = "PRODUCTION"
    case sandbox = "SANDBOX"
}

struct PurchaseInfo {
    let bundleName: String
    let id: String
    let environment: String
    let signedTransaction: String
    let transactionId: UInt64
    let signedDate: Int
    let purchaseDate: Int
    let quantity: Int
    let appAccountToken: String?
    let appLanguage: String
    let deviceIdentifier: String

    func toDictionaryPurchase() -> [String: Any] {
        var dict: [String: Any] = [
            "bundleName": bundleName,
            "productId": id,
            "environment": environment,
            "signedTransaction": signedTransaction,
            "transactionId": transactionId,
            "signedDate": signedDate,
            "purchaseDate": purchaseDate,
            "quantity": quantity,
            "appLanguage": appLanguage,
            "deviceIdentifier": deviceIdentifier
        ]
        if let token = appAccountToken {
            dict["appAccountToken"] = token
        }
        return dict
    }

    func toDictionarySubscription() -> [String: Any] {
        var dict: [String: Any] = [
            "bundleName": bundleName,
            "subscriptionId": id,
            "environment": environment,
            "signedTransaction": signedTransaction,
            "transactionId": transactionId,
            "signedDate": signedDate,
            "purchaseDate": purchaseDate,
            "appLanguage": appLanguage,
            "deviceIdentifier": deviceIdentifier
        ]
        if let token = appAccountToken {
            dict["appAccountToken"] = token
        }
        return dict
    }
}
struct TransactionVerification {
    static var initialRetryDelay: Double = 1.5
    static var maxRetryCount: Int = 7
    static var transactionId: UInt64 = 1
    static var type: TransactionProductType = .consumable
    private static var shouldCancel = false
    
    static func verify(param:PurchaseInfo,
                       transactionId: UInt64,
                       type: TransactionProductType,
                       completionHandler: @escaping (_ error: Error?, _ amount: Double) -> Void) {
        // Start the first attempt with the initial delay
        self.transactionId = transactionId
        self.type = type
        if param.id.contains("subscri") {
            subscriptionRechargeForIOS(parm: param, completionHandler: completionHandler)
        }else{
            inapPurchasesRechargeForIOS(parm: param, completionHandler: completionHandler)
        }
    }
    
    static func inapPurchasesRechargeForIOS(parm: PurchaseInfo, completionHandler: @escaping (_ error: Error?, _ amount: Double) -> Void)
    {
        PFCloud.callFunction(inBackground: "anv2_rechargeForIOS", withParameters: parm.toDictionaryPurchase()) { result, error in
            if let error = error {
                completionHandler(error, 0)
            }
            else if let parseObject = result as? [String: Any] {
                if let hasError = parseObject["hasError"] as? Bool,
                   let error = parseObject["error"] as? String,
                   let code = parseObject["errorCode"] as? Int,
                   hasError == true
                {
                    let customError = NSError(domain: "\(error)", code: code, userInfo: nil)
                    if code == 408
                    {
                        attemptVerification(retryCount: 0, currentDelay: initialRetryDelay) { error, amount in
                            completionHandler(customError, amount)
                        }
                    }
                    else
                    {
                        completionHandler(customError, 0)
                    }
                }
                else if let amount = parseObject["amount"] as? Double {
                    completionHandler(nil, amount)
                }
            }else{
                let customError = NSError(domain: "Unknown Error", code: 0, userInfo: nil)
                completionHandler(customError, 0)
            }
        }
    }
    
    static func subscriptionRechargeForIOS(parm: PurchaseInfo, completionHandler: @escaping (_ error: Error?, _ amount: Double) -> Void)
    {
        PFCloud.callFunction(inBackground: "anv2_registerSubscriptionForIOS", withParameters: parm.toDictionarySubscription()) { result, error in
            if let error = error {
                completionHandler(error, 0)
            }
            else if let parseObject = result as? [String: Any] {
                if let hasError = parseObject["hasError"] as? Bool,
                   let error = parseObject["error"] as? String,
                   let code = parseObject["errorCode"] as? Int,
                   hasError == true {
                    let customError = NSError(domain: "\(error)", code: code, userInfo: nil)
                    if code == 408
                    {
                        attemptVerification(retryCount: 0, currentDelay: initialRetryDelay) { error, amount in
                            completionHandler(customError, 0)
                        }
                    }
                    else
                    {
                        completionHandler(customError, 0)
                    }
                }
                else {
                    completionHandler(nil, 0)
                }
            }
            else
            {
                let customError = NSError(domain: "Unknown Error", code: 0, userInfo: nil)
                completionHandler(customError, 0)
            }
        }
    }
    
    static func attemptVerification(retryCount: Int, currentDelay: Double, completionHandler: @escaping (_ error: Error?, _ amount: Double) -> Void) {
        guard !shouldCancel else {
            let cancelError = NSError(domain: "TransactionVerification", code: -999, userInfo: [NSLocalizedDescriptionKey: "Operation was cancelled."])
            completionHandler(cancelError, 0)
            return
        }
        
        let params = ["transactionId": "\(transactionId)", "rechargeProductType": type.stringValue] as [String: Any]
        PFCloud.callFunction(inBackground: "checkAppleIAPTransaction", withParameters: params) { result, error in
            if let error = error {
                if retryCount < maxRetryCount {
                    let nextDelay = currentDelay + 1.0  // Increment delay by 1.0 second
                    DispatchQueue.global().asyncAfter(deadline: .now() + currentDelay) {
                        attemptVerification(retryCount: retryCount + 1, currentDelay: nextDelay,completionHandler:completionHandler)
                    }
                } else {
                    completionHandler(error, 0)
                }
            }
            else if let parseObject = result as? [String: Any] {
                if let hasError = parseObject["hasError"] as? Bool,
                   let error = parseObject["error"] as? String,
                   let code = parseObject["errorCode"] as? Int,
                   hasError == true {
                    let codeError = TCValidationError(code:code)
                    let customError = NSError(domain: codeError?.errorDescription ?? error, code: code, userInfo: nil)
                    completionHandler(customError, 0)
                }
                else if let found = parseObject["paymentTransactionFound"] as? Bool, found == true {
                    if let amount = parseObject["amount"] as? Double {
                        completionHandler(nil, amount)
                    }else{
                        completionHandler(nil, 0)
                    }
                }
                else
                {
                    let customError = NSError(domain: "Payment transaction not found", code: 0, userInfo: nil)
                    if retryCount < maxRetryCount {
                        let nextDelay = currentDelay + 1.0
                        DispatchQueue.global().asyncAfter(deadline: .now() + currentDelay) {
                            attemptVerification(retryCount: retryCount + 1, currentDelay: nextDelay,completionHandler:completionHandler)
                        }
                    } else {
                        completionHandler(customError, 0)
                    }
                }
            } else {
                let customError = NSError(domain: "Unknown Error", code: 0, userInfo: nil)
                if retryCount < maxRetryCount {
                    let nextDelay = currentDelay + 1.0
                    DispatchQueue.global().asyncAfter(deadline: .now() + currentDelay) {
                        attemptVerification(retryCount: retryCount + 1, currentDelay: nextDelay,completionHandler:completionHandler)
                    }
                } else {
                    completionHandler(customError, 0)
                }
            }
        }
    }
    static func cancelVerification() {
        shouldCancel = true
    }
}

enum TransactionProductType
{
    case consumable, subscription
    
    var stringValue:String
    {
        switch self {
        case .consumable:
            return "Consumable"
        case .subscription:
            return "Subscription"
        }
    }
}
