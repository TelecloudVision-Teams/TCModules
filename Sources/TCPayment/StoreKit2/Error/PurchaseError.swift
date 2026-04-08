//
//  File.swift
//
//
//  Created by Ali on 06/09/2024.
//

import Foundation
import StoreKit

@objc public enum PurchaseErrorCode: Int {
    case cancel = 1
    case pending = 2
    case general = 3
}

@objc public class PurchaseError: NSObject, LocalizedError {
    
    @objc public let code: PurchaseErrorCode
    @objc public let productIdentifier: String

    @objc public init(code: PurchaseErrorCode, productIdentifier: String) {
        self.code = code
        self.productIdentifier = productIdentifier
    }

    public var errorDescription: String? {
        switch code {
        case .cancel:
            return "User Cancelled: Cannot purchase product \(productIdentifier) from restore purchases path"
        case .pending:
            return "Deferred: Cannot purchase product \(productIdentifier) from restore purchases path"
        case .general:
            return "Error: Cannot purchase product \(productIdentifier) from restore purchases path"
        }
    }

    public var nsError: NSError {
        return NSError(
            domain: "PurchaseErrorDomain",
            code: code.rawValue,
            userInfo: [
                NSLocalizedDescriptionKey: errorDescription ?? "Unknown purchase error",
                "productIdentifier": productIdentifier
            ]
        )
    }
}
