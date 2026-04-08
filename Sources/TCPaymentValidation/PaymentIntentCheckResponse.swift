//
//  PaymentIntentCheckResponse.swift
//
//  Created by Admin on 05/07/2022.
//

import Foundation

public struct PaymentIntentCheckResponse {
    var success:Bool = false
    var error: Error?
    
    public init?(parseObject:[String:Any]?) {
        if let parseObject = parseObject,
           let hasError = parseObject["hasError"] as? Bool,
           let error = parseObject["error"] as? String,
           let code = parseObject["errorCode"] as? Int,
           hasError == true
        {
            let customError = NSError(domain: error, code: code, userInfo: nil)
            self.error = customError
        }
        else if let parseObject = parseObject,
                let paymentIntentFound = parseObject["paymentIntentFound"] as? Bool
        {
            self.success = paymentIntentFound
        }
        else
        {
            return nil
        }
    }
}
