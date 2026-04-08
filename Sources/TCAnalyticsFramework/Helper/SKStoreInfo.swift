//
//  AnalyticsExtras.swift
//  TCAnalytics
//
//  Created by Ali on 08/05/2025.
//

import Foundation

struct SKStoreInfo:Codable {
    var storefront: String
    var storefrontId: String
    var storefrontPrice: Double
    var storefrontCurrency: String
    var notificationType: String
    
    static var empty: SKStoreInfo {
        SKStoreInfo(
            storefront: "",
            storefrontId: "",
            storefrontPrice: 0,
            storefrontCurrency: "",
            notificationType: ""
        )
    }
    init(storefront: String,
               storefrontId: String,
               storefrontPrice: Double,
               storefrontCurrency: String,
               notificationType: String)
    {
        self.storefront = storefront
        self.storefrontId = storefrontId
        self.storefrontPrice = storefrontPrice
        self.storefrontCurrency = storefrontCurrency
        self.notificationType = notificationType
    }
    func toDictionary() -> [String: Any]? {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(self)
            
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            return jsonObject as? [String: Any]
        } catch {
            print("AnalyticsTransactionLog → Failed to convert to dictionary: \(error)")
            return nil
        }
    }
}
