//
//  PaymentIntentResponse.swift
//  TCPayment
//
//  Created by Admin on 13/07/2022.
//

import Foundation
import TCPaymentValidation

@objcMembers
public class PaymentIntentResponse:NSObject {
    var amount:Double = 0
    var intentStatus:PaymentIntentStatus = .paymentMethodRequired
    var intent: String = ""
    var ephemeralSecret: String = ""
    var customerId: String = ""
    var intentId:String = ""
    var error: Error?
    var confirmed:Bool = false
    
    public func allInfo() -> [String:Any]
    {
        return [
            "amount": amount,
            "intentStatus": intentStatus.rawVal,
            "intent": intent,
            "ephemeralSecret": ephemeralSecret,
            "customerId": customerId,
            "intentId": intentId,
            "error": error,
            "platform": "IOS",
            "deviceIdentifier": TCPayment.deviceIdentifier
        ]
    }
    public override init() {
        
    }
    public init?(parseObject:[String:Any]?) {
        if let parseObject = parseObject{
            if let amount = parseObject["amount"] as? Double,
               let paymentIntentStatus = parseObject["paymentIntentStatus"] as? String,
               let paymentIntent = parseObject["paymentIntent"] as? String,
               let ephemeralSecret = parseObject["ephemeralKeySecret"] as? String,
               let customerId = parseObject["customerId"] as? String,
               let paymentIntentId = parseObject["paymentIntentId"] as? String
            {
                self.amount = amount
                self.intent = paymentIntent
                self.ephemeralSecret = ephemeralSecret
                self.customerId = customerId
                self.intentId = paymentIntentId
                self.intentStatus = PaymentIntentStatus(rawValue: paymentIntentStatus)
                if let confirmed = parseObject["confirm"] as? Bool {
                    self.confirmed = confirmed
                }
            }
            else if let _ = parseObject["hasError"] as? Bool,
                    let code = parseObject["errorCode"] as? Int
            {
                let error = CardErrorCode.makeError(code: code, message: parseObject["error"] as? String)
                self.error = error
            }
        }
        else
        {
            return nil
        }
    }
}

