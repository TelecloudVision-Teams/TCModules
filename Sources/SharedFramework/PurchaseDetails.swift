//
//  File.swift
//
//
//  Created by Telecloud on 04/06/2024.
//

import UIKit
import StoreKit

/// Purchased product

public protocol Purchased {
    var productId: String { get }
    var quantity: Int { get }
    var originalPurchaseDate: Date { get }
}

@objc public class PurchaseDetails: NSObject {
    public let productId: String
    public let appLanguage: String
    public let transaction: StoreKitTransaction?
    
    public var dictionary:[String:Any]
    {
        var params: [String: Any] = [:]
        
        params["isAppleStoreKit2"] = 1
        params["ReceiptDataBase64"] = ""
        params["ReceiptDataBase64Original"] = transaction?.signedTransaction ?? ""
        params["BundleName"] = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
        params["AppLanguage"] = appLanguage
        params["PlatformVersion"] = UIDevice.current.systemVersion
        params["DeviceIdentifier"] = UIDevice.deviceIdentifier.value ?? ""
        params["quantity"] = transaction?.quantity

        if let timeInterval = transaction?.signedDate?.timeIntervalSince1970 {
            params["signedDate"] = timeInterval*1000
        }
        if let timeInterval = transaction?.purchaseDate.timeIntervalSince1970 {
            params["purchaseDate"] = timeInterval*1000
        }
        
        return params
    }
    public init(productId: String,
                appLanguage: String,
                transaction: StoreKitTransaction? = nil)
    {
        self.productId = productId
        self.appLanguage = appLanguage
        self.transaction = transaction
    }
}

@objc public class StoreKitTransaction: NSObject {
    public let productID: String
    public let originalTransactionID: String?
    public let transactionID: String?
    public let purchaseDate: Date
    public let signedDate: Date?
    public let transactionState: TransactionState
    public let signedTransaction: String?
    public let quantity: Int = 1

    public init(from transaction: Transaction, signedTransaction: String) {
        self.productID = transaction.productID
        self.transactionID = String(transaction.id)
        self.originalTransactionID = String(transaction.originalID)
        self.purchaseDate = transaction.purchaseDate
        self.transactionState = TransactionState(from: transaction)
        self.signedTransaction = signedTransaction
        self.signedDate = transaction.signedDate
    }
}

@objc public enum TransactionState: Int {
    case purchased
    case failed
    case restored
    case deferred
    case revoked
    
    init(from transaction: Transaction) {
        if transaction.revocationDate != nil {
            self = .revoked
        } else if transaction.isUpgraded {
            self = .failed // Use .failed or a custom state if applicable
        } else {
            self = .purchased
        }
    }
}
