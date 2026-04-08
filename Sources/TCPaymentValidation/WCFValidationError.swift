//
//  WCFValidationError.swift
//  TCPaymentValidation
//
//  Created by Telecloud on 15/01/2024.
//

import Foundation

public enum WCFValidationError: Error {
    
    case userUnSubscribedEndTransaction(Bool)
    case error(Error)
}

extension WCFValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .userUnSubscribedEndTransaction(_):
            return "User is UnSubscribed"
        case .error(let error):
            return "Error: \(error)"
        }
    }
}
