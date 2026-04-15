//
//  TransactionReason.swift
//  TCSharedFramework
//
//  Created by Ali on 08/05/2025.
//

import StoreKit

enum TransactionReason: String {
    case didRenew = "DID_RENEW"
    case subscribed = "SUBSCRIBED"
    case oneTimeCharge = "ONE_TIME_CHARGE"
    case unknown = "UNKNOWN"
    
    static func from(transaction: Transaction, jwt: String) -> TransactionReason {
        switch transaction.productType {
        case .autoRenewable:
            if #available(iOS 17.0, *) {
                switch transaction.reason {
                case .purchase:
                    return .subscribed
                case .renewal:
                    return .didRenew
                default:
                    return .unknown
                }
            } else {
                if let reason = decodeTransactionReason(from: jwt)?.uppercased() {
                    switch reason {
                    case "PURCHASE", "RESUBSCRIBE":
                        return .subscribed
                    case "RENEWAL":
                        return .didRenew
                    default:
                        break
                    }
                }
                // In case JWT failed to decode
                return transaction.id == transaction.originalID ? .subscribed : .didRenew
            }

        case .consumable, .nonConsumable:
            return .oneTimeCharge

        default:
            return .unknown
        }
    }
}

struct JWTTransactionPayload: Decodable {
    let transactionReason: String?
}

func decodeTransactionReason(from jws: String) -> String? {
    // JWT is composed of 3 parts: header.payload.signature
    let components = jws.split(separator: ".")
    guard components.count == 3 else {
        print("Invalid JWT format")
        return nil
    }
    
    let payloadSegment = components[1]
    
    // Base64url decode
    var base64 = payloadSegment
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    // Add padding if necessary
    while base64.count % 4 != 0 {
        base64 += "="
    }
    
    guard let payloadData = Data(base64Encoded: base64) else {
        print("Failed to base64 decode payload")
        return nil
    }
    
    do {
        let decodedPayload = try JSONDecoder().decode(JWTTransactionPayload.self, from: payloadData)
        return decodedPayload.transactionReason
    } catch {
        print("Failed to decode payload: \(error)")
        return nil
    }
}
