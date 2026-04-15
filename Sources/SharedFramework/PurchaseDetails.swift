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
        params["ProductTypeId"] = productId.lowercased().contains("subscri") ? 3 : 1
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
    public let storeId:String?
    public let storeCurrency:String?
    public let storeCountry:String?
    public let storePrice:Double
    public let notificationType:String?
    public let isSubscription:Bool
    public let webOrderLineItemID:String?
    public let productType:Product.ProductType?

    public init(from transaction: Transaction, signedTransaction: String) {
        self.productID = transaction.productID
        self.transactionID = String(transaction.id)
        self.originalTransactionID = String(transaction.originalID)
        self.purchaseDate = transaction.purchaseDate
        self.transactionState = TransactionState(from: transaction)
        self.signedTransaction = signedTransaction
        self.signedDate = transaction.signedDate
        self.storePrice = NSDecimalNumber(decimal: transaction.price ?? 0).doubleValue
        self.notificationType = TransactionReason.from(transaction: transaction, jwt: signedTransaction).rawValue
        self.isSubscription = transaction.productType == .autoRenewable || transaction.productType == .nonRenewable
        self.webOrderLineItemID = transaction.webOrderLineItemID
        self.productType = transaction.productType
        
        if #available(iOS 17.0, *) {
            self.storeId = transaction.storefront.id
            self.storeCountry = transaction.storefront.countryCode
            self.storeCurrency = transaction.storefront.currency?.identifier
        }
        else
        {
            self.storeId = nil
            self.storeCountry = transaction.storefrontCountryCode
            if #available(iOS 16.0, *)
            {
                self.storeCurrency = transaction.currency?.identifier ?? "USD"
            }
            else
            {
                self.storeCurrency = transaction.currencyCode ?? "USD"
            }
        }
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
