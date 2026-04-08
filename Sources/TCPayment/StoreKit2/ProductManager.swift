//
//  File.swift
//  
//
//  Created by Ali on 05/09/2024.
//

import Foundation
import StoreKit

class ProductManager {
    static var productFetcher: ProductFetching = StoreKitProductFetcher()

    static func fetchInformation(_ productIds: Set<String>,
                                 completion: @escaping (_ results: [Product]?, _ error: Error?) -> Void) {
        Task {
            do {
                let products = try await productFetcher.products(for: productIds)
                if !products.isEmpty {
                    completion(products, nil)
                } else {
                    completion(nil, NSError(domain: "Type mismatch", code: 0, userInfo: nil))
                }
            } catch {
                completion(nil, error)
            }
        }
    }
}
