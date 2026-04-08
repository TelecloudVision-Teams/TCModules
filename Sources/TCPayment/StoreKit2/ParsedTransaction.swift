//
//  ParsedTransaction.swift
//  TCPayment
//
//  Created by Ali on 17/04/2025.
//

import StoreKit

public struct ParsedTransaction {
    public let signedType: Transaction
    public let jwsRepresentation: String
    public let verificationError: Error?
    
    public init(signedType: Transaction,
                jwsRepresentation: String,
                verificationError: Error?) {
        self.signedType = signedType
        self.jwsRepresentation = jwsRepresentation
        self.verificationError = verificationError
    }
}
