//
//  IAPTransactionState.swift
//
//  Created by Admin on 05/07/2022.
//

import Foundation

@objc public enum TCPaymentValidationTransactionState : Int{
    
    case CreditCardStartedValidatePayment
    case CreditCardFailedValidatePayment
    case CreditCardSuccessValidatePayment
    
    case IAPStartedValidatePayment
    case IAPFailedValidatePayment
    case IAPSuccessValidatePayment
    
    public func value() -> String {
      switch self {
      case .CreditCardStartedValidatePayment: return "Credit Card Payment validation started"
      case .CreditCardFailedValidatePayment: return "Credit Card Payment validation failed"
      case .CreditCardSuccessValidatePayment: return "Credit Card Payment validation success"
      case .IAPStartedValidatePayment: return "IAP Payment validation started"
      case .IAPFailedValidatePayment: return "IAP Payment validation failed"
      case .IAPSuccessValidatePayment: return "IAP Payment validation success"
      }
    }
}

@objc public enum PaymentValidator: Int {
    case parse
    case wcf
}
