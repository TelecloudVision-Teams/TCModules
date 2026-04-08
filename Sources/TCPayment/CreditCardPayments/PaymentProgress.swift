//
//  PaymentProgress.swift
//  TCPayment
//
//  Created by Ali on 07/04/2025.
//

import Foundation
import TCSharedFramework

@objcMembers
public class PaymentProgress: NSObject {
    public let state: TCPaymentTransactionState
    public let intentDetails: IntentPurchaseDetails?
    public let error: Error?

    public init(state: TCPaymentTransactionState, intentDetails: IntentPurchaseDetails?, error: Error?) {
        self.state = state
        self.intentDetails = intentDetails
        self.error = error
    }
}
