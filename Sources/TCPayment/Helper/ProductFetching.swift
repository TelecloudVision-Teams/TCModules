//
//  ProductFetching.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//

import StoreKit
protocol ProductFetching {
    func products(for ids: Set<String>) async throws -> [Product]
}
