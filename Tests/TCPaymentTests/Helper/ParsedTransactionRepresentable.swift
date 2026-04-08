//
//  ParsedTransactionRepresentable.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//


struct ParsedTransactionRepresentable {
    let signedType: TransactionRepresentable
    let jwsRepresentation: String
    let verificationError: Error?
}
