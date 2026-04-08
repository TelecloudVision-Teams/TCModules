//
//  iAPValidationError.swift
//  TemplateApp
//
//  Created by Admin on 25/11/2020.
//  Copyright © 2020 Hayateh. All rights reserved.
//

import Foundation

public enum TCValidationError: Error {
    
    case invalidProduct
    case invalidTransaction
    case methodNotSet
    case invalidTransactionId
    case invalidReceipt(error:Error)
    case general(error:Error)
    case alreadyConsumed
    case inQueue
    case iTunesError
    case AppStoreConnectionErroor
    case serverError
    case subscriptionAlreadyActive
    case noRestoreAvailable
    case restoreConsumed
    case invalidResponse
    case parameters

    public init(error:Error)
    {
        self = .general(error: error)
    }
    public init?(code: Int, reason:String? = nil, isWallet:Bool = false) {
        switch code {
        case 302:
            self = .restoreConsumed
        case 303:
            self = .subscriptionAlreadyActive
        case 304:
            self = .noRestoreAvailable
        case 400:
            self = .invalidTransaction
        case 402,
            501:
            self = .invalidProduct
        case 406:
            self = .invalidResponse
        case 409:
            self = .alreadyConsumed
        case 599:
            self = .iTunesError
        case -1012:
            self = .AppStoreConnectionErroor
        case 500,
             503,
             141,
             100:
            self = .serverError
        case 10473:
            self = .inQueue
        default:
            return nil
        }
    }
}

extension TCValidationError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidTransactionId:
            return "Transaction Identifier is null"
        case .invalidResponse:
            return "Invalid Response from Server, could not read JSON"
        case .methodNotSet:
            return "Validation method is not set"
        case .invalidReceipt(let error):
            return "Invalid Receipt: \(error)"
        case .alreadyConsumed:
            return "Purchase Already Consumed"
        case .serverError:
            return "Could not reach server"
        case .inQueue:
            return "Pending purchase exists in queue"
        case .parameters:
            return "Parameters not set"
        case .iTunesError:
            return "Could not connect to iTunes"
        case .subscriptionAlreadyActive:
            return "Subscription already active"
        case .noRestoreAvailable:
            return "No restore available"
        case .restoreConsumed:
            return "Restore already consumed"
        case .general(let error):
            return "\(error)"
        case .AppStoreConnectionErroor:
            return "Could not connect to AppStore"
        case .invalidTransaction:
            return "Transaction is invalid"
        case .invalidProduct:
            return "Product is invalid"
        }
    }
}
extension TCValidationError
{
    public static func getError(from error:TCValidationError) -> NSError
    {
        var code = 0
        switch error {
        case .restoreConsumed:
            code = 302
        case .subscriptionAlreadyActive:
            code = 303
        case .noRestoreAvailable:
            code = 304
        case .invalidTransaction:
            code = 400
        case .invalidProduct:
            code = 402
        case .invalidResponse:
            code = 406
        case .alreadyConsumed:
            code = 409
        case .iTunesError:
            code = 599
        case .AppStoreConnectionErroor:
            code = -1012
        case .serverError:
            code = 500
        case .inQueue:
            code = 10473
        default:
            code = 0
        }
        return NSError(domain: "Validation Error: \(error.errorDescription ?? "\(code)")", code: code, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription])
    }
}
