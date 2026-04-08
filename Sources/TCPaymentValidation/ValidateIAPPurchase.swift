//
//  ValidateIAPPurchase.swift
//  TCPaymentValidation
//
//  Created by Telecloud on 15/01/2024.
//

import Foundation

public struct ValidateIAPPurchase:Codable {
    public var error:String
    public var hasError:Bool
    public var endTransaction:Bool
    public var isGeneric:Bool
    public var id:Int
    public var isSubscribed:Bool
    public var status:Int
    public var valid:Bool
    
    enum CodingKeys: String, CodingKey {
        case error = "error"
        case hasError = "hasError"
        case id = "id"
        case isSubscribed = "isSubscribed"
        case status = "status"
        case valid = "valid"
        case endTransaction = "endTransaction"
        case isGeneric = "isGeneric"
    }
}

struct ValidateIAPPurchaseResponse: Codable {
    let getArticleDataList: ValidateIAPPurchase
    
    func decodeFormLinksItems() -> (ValidateIAPPurchase) {
        return getArticleDataList
    }
}

