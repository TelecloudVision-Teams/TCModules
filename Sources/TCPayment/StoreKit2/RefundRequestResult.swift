//
//  RefundRequestResult.swift
//  TCPayment
//
//  Created by Ali on 24/04/2025.
//


@objc public enum RefundRequestResult: Int {
    case success
    case cancelled
    case duplicateRequest
    case failed
    case windowSceneUnavailable
    case transactionUnavailable
    case unknownError
}
