//
//  PurchaseContext.swift
//  TCPayment
//
//  Created by Ali on 22/10/2025.
//

import UIKit
import TCSharedFramework

struct PurchaseContext {
    let config: PurchaseConfig
    var intentDetails: IntentPurchaseDetailsBuilder

    let report: (_ state: TCPaymentTransactionState,
                 _ details: IntentPurchaseDetails?,
                 _ error: Error?,
                 _ progress: @escaping (PaymentProgress) -> Void) -> Void

    let callCloud: (_ name: String, _ params: [String: Any],
                    _ done: @escaping (_ obj: Any?, _ error: Error?) -> Void) -> Void

    let displayIntent: (_ hostVC: UIViewController,
                        _ response: PaymentIntentResponse,
                        _ type: RechargeType,
                        _ completed: @escaping (Error?) -> Void,
                        _ progress: @escaping (TCPaymentTransactionState, Error?) -> Void) -> Void

    let validateCard: (_ done: @escaping (Error?) -> Void,
                       _ progress: @escaping (TCPaymentTransactionState, Error?) -> Void) -> Void
}
