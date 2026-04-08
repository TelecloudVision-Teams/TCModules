//
//  StripeDisplayIntent.swift
//  TCPayment_iOS
//
//  Created by Admin on 04/07/2022.
//  Copyright © 2022 musevisions. All rights reserved.
//

import UIKit
import Foundation
import StripePaymentSheet
import Stripe
import TCPaymentValidation
import ParseCore
import TCSharedFramework

class CreditCard
{
    let config: PurchaseConfig
    var intentPurchaseDetails:IntentPurchaseDetailsBuilder
    var purchaseAmount:Double = 0
    
    init(config: PurchaseConfig) {
        guard let key = TCPayment.creditCardKey else
        {
            fatalError("Credit Card API Key is missing")
        }
        self.config = config
        self.intentPurchaseDetails = IntentPurchaseDetailsBuilder()
        self.purchaseAmount = 0
        StripeAPI.defaultPublishableKey = key
    }
    
    func purchase(completion:@escaping (_ error:Error?,_ amount: Double) -> Void,
                  progress: @escaping (_ progress: PaymentProgress) -> Void) {
        
        let ctx = PurchaseContext(config: config,
                                  intentDetails: intentPurchaseDetails,
                                  report: { [weak self] state, details, error, progressHandler in
            self?.reportProgress(state: state, details: details, error: error, progressHandler: progressHandler)
        },
                                  callCloud: { name, params, done in
            PFCloud.callFunction(inBackground: name, withParameters: params, block: done)
        },
                                  displayIntent: { [weak self] hostVC, resp, type, completed, prog in
            self?.displayIntent(in: hostVC, for: resp, rechargeType: type, completion: completed, progress: prog)
        },
                                  validateCard: { [weak self] done, prog in
            self?.validateCreditCardPayment(completion: { err in done(err) },
                                            progress: { s, e in prog(s, e) })
        })

        let flow: PurchaseFlow = (config.intentConfig != nil) ? ExistingIntentFlow() : NewIntentFlow()

        flow.start(ctx: ctx, completion: completion, progress: progress)
    }
    
    func handleURLCallback(url: URL) -> Bool {
        return StripeAPI.handleURLCallback(with: url)
    }
    
    /// Validate Credit Card Payment Cloud Function
    func validateCreditCardPayment(completion:@escaping (Error?) -> Void, progress:@escaping (_ state:TCPaymentTransactionState,_ error:Error?)->()){
        DispatchQueue.main.asyncAfter(deadline: .now()+1) { [weak self] in
            progress(.LogStripeIntentCheckingStarted,nil)
            TCPaymentValidation.validateCreditCardPayment(intentId: self?.intentPurchaseDetails.intentID ?? "",
                                                          rechargeType: self?.intentPurchaseDetails.rechargeProductType ?? "") { error in
                if error == nil
                {
                    progress(.LogStripeIntentCheckingSuccess,nil)
                    completion(nil)
                }
                else
                {
                    progress(.LogStripeIntentCheckingFailure,error)
                    completion(error)
                }
            }
        }
    }
    private func displayIntent(in viewcontroller: UIViewController,
                               for response: PaymentIntentResponse, rechargeType:RechargeType, completion:@escaping (Error?) -> Void, progress:@escaping (_ state:TCPaymentTransactionState,_ error:Error?)->())
    {
        var configuration = PaymentSheet.Configuration()
        let secret = response.intent
        configuration.customer = .init(id: response.customerId,
                                       ephemeralKeySecret: response.ephemeralSecret)
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: secret,
                                        configuration: configuration)
        paymentSheet.present(from: config.viewController) { [weak self] result in
            switch result {
            case .canceled:
                self?.retrievePaymentIntent(intentId: response.intentId, clientSecret: secret) { success in
                    if  success
                    {
                        // Treat as completed
                        DispatchQueue.main.async {
                            progress(.LogStripeIntentFlowCompleted, nil)
                            self?.validateCreditCardPayment(completion: completion, progress: progress)
                        }
                    } else {
                        let error = NSError(domain: "Canceled", code: -2)
                        DispatchQueue.main.async {
                            progress(.LogStripeIntentFlowCanceled, error)
                            completion(error)
                        }
                    }
                }
            case .completed:
                progress(.LogStripeIntentFlowCompleted,nil)
                self?.validateCreditCardPayment(completion:completion,progress: progress)
            case .failed(let error):
                let newError = self?.fetchPaymentSheetError(error: error, intentId: response.intentId)
                DispatchQueue.main.async {
                    progress(.LogStripeIntentFlowError,newError)
                    completion(newError)
                }
            }
        }
    }
    
    private func fetchPaymentSheetError(error:Error?, intentId:String) -> Error
    {
        var text = "Error from stripe payment sheet with intent id: \(intentId)"
        
        var newError:NSError
        if let error = error
        {
            newError = NSError(domain: "\(text) - \(error._domain)", code: error._code, userInfo: error._userInfo as? [String : Any])
        }
        else
        {
            text = "Payment intent is not found - " + text
            newError = NSError(domain: text, code: 0, userInfo: nil)
        }
        return newError
    }
    private func reportProgress(state: TCPaymentTransactionState,
                                details: IntentPurchaseDetails? = nil,
                                error: Error? = nil,
                                progressHandler: (PaymentProgress) -> Void) {
        let currentProgress = PaymentProgress(state: state, intentDetails: details, error: error)
        progressHandler(currentProgress)
    }
    private func retrievePaymentIntent(intentId: String, clientSecret:String, completion: @escaping (Bool) -> Void) {
        STPAPIClient.shared.retrievePaymentIntent(withClientSecret: clientSecret) { intent, error in
            switch intent?.status
            {
            case .succeeded:
                completion(true)
            default:
                completion(false)
            }
        }
    }
}

