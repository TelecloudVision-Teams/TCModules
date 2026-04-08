//
//  StoreKitProductFetcher.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//

import StoreKit
struct StoreKitProductFetcher: ProductFetching {
    func products(for ids: Set<String>) async throws -> [Product] {
        return try await Product.products(for: ids)
    }
}
