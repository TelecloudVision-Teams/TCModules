//
//  MockProduct.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//


//import Testing
//import StoreKit
//@testable import TCPayment
//
//struct ProductManagerTests {
//
//    struct DummyError: Error {}
//
//    @Test
//    func fetchInformationReturnsProducts() async throws {
//        let mockProducts: [Product] = [] // Replace with stub if needed
//        ProductManager.productFetcher = MockProduct(mockResult: mockProducts, mockError: nil)
//
//        var called = false
//        ProductManager.fetchInformation(["test.product"]) { results, error in
//            #expect(results?.isEmpty == true)
//            #expect(error == nil)
//            called = true
//        }
//
//        // Allow async task to complete
//        try await Task.sleep(nanoseconds: 100_000_000)
//        #expect(called == true)
//    }
//
//    @Test
//    func fetchInformationReturnsError() async throws {
//        ProductManager.productFetcher = MockProduct(mockResult: nil, mockError: DummyError())
//
//        var receivedError: Error?
//        ProductManager.fetchInformation(["fail.product"]) { results, error in
//            receivedError = error
//        }
//
//        try await Task.sleep(nanoseconds: 100_000_000)
//        #expect(receivedError is DummyError)
//    }
//
//    @Test
//    func fetchInformationReturnsNilForEmptyProducts() async throws {
//        ProductManager.productFetcher = MockProduct(mockResult: [], mockError: nil)
//
//        var receivedError: Error?
//        var result: [Product]?
//        ProductManager.fetchInformation(["empty.product"]) { results, error in
//            result = results
//            receivedError = error
//        }
//
//        try await Task.sleep(nanoseconds: 100_000_000)
//        #expect(result == nil)
//        #expect(receivedError != nil)
//        #expect((receivedError as? NSError)?.domain == "Type mismatch")
//    }
//}
