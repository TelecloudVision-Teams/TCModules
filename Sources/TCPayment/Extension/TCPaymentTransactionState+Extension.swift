//
//  File.swift
//  
//
//  Created by Ali on 05/09/2024.
//

import Foundation
import TCSharedFramework

enum ActionType {
    case appleState
    case serverCheck
    case serverSuccess
    case serverFailed
}

extension TCPaymentTransactionState
{
    static func fetchState(for product: String, verified: Bool? = nil, action: ActionType) -> TCPaymentTransactionState {
        let isSubscription = product.isSubscription

        switch action {
        case .appleState:
            return verified == true ? (isSubscription ? .LogSubscriptionSuccessPurchase : .LogIAPSuccessPurchase)
                                    : (isSubscription ? .LogSubscriptionFailedPurchase : .LogIAPFailedPurchase)
        case .serverCheck:
            return isSubscription ? .LogSubscriptionCheckPurchaseBeforeSending : .LogIAPCheckPurchaseBeforeSending
        case .serverSuccess:
            return isSubscription ? .LogSubscriptionSuccessPurchaseAfterSendingData : .LogIAPSuccessPurchaseAfterSendingData
        case .serverFailed:
            return isSubscription ? .LogSubscriptionFailedPurchaseAfterSendingData : .LogIAPFailedPurchaseAfterSendingData
        }
    }
}
