//
//  MockProduct 2.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//


import StoreKit
struct MockProduct: ProductFetching {
    let mockResult: [Product]?
    let mockError: Error?

    func products(for ids: Set<String>) async throws -> [Product] {
        if let error = mockError {
            throw error
        }
        return mockResult ?? []
    }
}
