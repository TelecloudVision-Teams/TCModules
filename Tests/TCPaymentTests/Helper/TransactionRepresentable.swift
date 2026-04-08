//
//  TransactionRepresentable.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//

import StoreKit
protocol TransactionRepresentable {
    var productID: String { get }
}
extension Transaction: TransactionRepresentable {}
