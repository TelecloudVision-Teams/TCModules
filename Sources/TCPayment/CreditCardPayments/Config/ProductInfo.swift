//
//  ProductInfo.swift
//  TCPayment
//
//  Created by Ali on 08/04/2025.
//

import Foundation
@objcMembers
public class ProductInfo: NSObject {
    public let type: RechargeType
    public var id: String

    public init(type: RechargeType, id: String) {
        self.type = type
        self.id = id
    }
    public init(type: RechargeType) {
        self.type = type
        self.id = ""
    }
}
