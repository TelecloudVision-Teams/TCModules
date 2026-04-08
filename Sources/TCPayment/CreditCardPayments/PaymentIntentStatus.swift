//
//  PaymentIntentStatus.swift
//  TCPayment
//
//  Created by Admin on 13/07/2022.
//

import Foundation

public enum PaymentIntentStatus:Equatable {
    case succeeded
    case actionRequired
    case paymentMethodRequired
    case failed
    
    public init(rawValue: String) {
        switch rawValue {
        case "requires_payment_method":
            self = .paymentMethodRequired
        case "requires_action":
            self = .actionRequired
        case "succeeded":
            self = .succeeded
        case "failed":
            self = .failed
        default:
            self = .paymentMethodRequired
        }
    }
    
    var rawVal:String
    {
        switch self {
        case .succeeded:
            return "succeeded"
        case .actionRequired:
            return "requires_action"
        case .paymentMethodRequired:
            return "requires_payment_method"
        case .failed:
            return "failed"
        }
    }
}
