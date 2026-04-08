//
//  ParsedTransactionTests.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//


import Testing

struct ParsedTransactionTests {
    
    struct DummyError: Error {}

    @Test
    func parsedTransactionStoresValuesCorrectly() async throws {
        let mockTransaction = MockTransaction(productID: "com.test.product")
        let jws = "fake.jwt.token"
        let error: Error? = DummyError()
        
        let parsed = ParsedTransactionRepresentable(
            signedType: mockTransaction,
            jwsRepresentation: jws,
            verificationError: error
        )
        
        #expect(parsed.signedType.productID == "com.test.product")
        #expect(parsed.jwsRepresentation == "fake.jwt.token")
        #expect(parsed.verificationError is DummyError)
    }

    @Test
    func parsedTransactionHandlesNilError() async throws {
        let mockTransaction = MockTransaction(productID: "com.test.product")
        let jws = "another.fake.jwt"
        
        let parsed = ParsedTransactionRepresentable(
            signedType: mockTransaction,
            jwsRepresentation: jws,
            verificationError: nil
        )
        
        #expect(parsed.verificationError == nil)
    }
}