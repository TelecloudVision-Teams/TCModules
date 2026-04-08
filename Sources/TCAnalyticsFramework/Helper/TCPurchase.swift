//
//  BranchPurchase.swift
//  AnalyticsFramework
//
//  Created by Ali on 29/04/2024.
//

import Foundation

enum TCPurchaseType
{
    case iAP, Subscription, other
    
    var stringValue:String
    {
        switch self
        {
        case .iAP: return "inApp"
        case .Subscription: return "Subscription"
        case .other: return "money"
        }
    }
}
struct TCPurchase
{
    /// Product title
    var title:String
    
    /// Product Price
    var price:Double
    
    /// Product Identifier
    var productId:String
    
    /// Application Language
    var language:TCLanguage
    
    /// Purchase type: inapp, 'other' should be mapped as 'money' due to business decision representation
    var type:TCPurchaseType = .other
    
    /// Purchase transaction Identifier
    var transactionId:String
    
    /// User Identifier of the purchase
    var userId:String?
    
    var parameters:[String:String]
    {
        
        return ["AppLanguage":language.string,
                "product_type":type.stringValue,
                "product_transaction_id":transactionId,
                "user_id":userId ?? "N/A"
        ]
    }
}
