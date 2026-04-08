//
//  CardErrorCode.swift
//  TCPayment
//
//  Created by Ali on 22/10/2025.
//

import Foundation

@objc public enum CardErrorCode: Int {
    case intentFetchFailure = 503                       // Payment intent creation error
    case unhandled = 500                                // Unhandled server error
    case invalidRechargeType = -1                       // Invalid recharge type
    case professionalNotFound = 405                     // Professional not found
    case packageNotFound = 406                          // Package not found
    case dataLookupIssue = 403                          // DB query issue

    private static let errorDomain = "com.telecloud.tcpayment"

    static func makeError(code: Int, message: String?) -> NSError {
        let msg = message ?? "Unknown error"
        return NSError(
            domain: errorDomain,
            code: code,
            userInfo: [
                NSLocalizedDescriptionKey: msg
            ]
        )
    }

    static func from(code: Int) -> CardErrorCode? {
        return CardErrorCode(rawValue: code)
    }
}
