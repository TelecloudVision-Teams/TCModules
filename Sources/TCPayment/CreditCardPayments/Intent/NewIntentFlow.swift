//
//  NewIntentFlow.swift
//  TCPayment
//
//  Created by Ali on 22/10/2025.
//

import UIKit
import TCSharedFramework

final class NewIntentFlow: PurchaseFlow {
    func start(ctx: PurchaseContext,
               completion: @escaping (Error?, Double) -> Void,
               progress: @escaping (PaymentProgress) -> Void)
    {
        var details = ctx.intentDetails
        details.productId = ctx.config.product.id
        details.appLanguage = TCPayment.language.localeIdentifier
        details.rechargeProductType = ctx.config.product.type.description
        details.professionalId = ctx.config.preferences.professionalId

        DispatchQueue.main.async {
            ctx.report(.LogStripeIntentPurchaseStarted, details.build(), nil, progress)
        }

        ctx.callCloud("createPaymentIntent", ctx.config.apiVals) { obj, err in
            if let err = err {
                DispatchQueue.main.async {
                    IntentFetchMessage.message = err.localizedDescription
                    ctx.report(.LogStripeIntentFetchFailure, details.build(), err, progress)
                    completion(err, 0)
                }
                return
            }

            guard
                let po = obj as? [String: Any],
                let resp = PaymentIntentResponse(parseObject: po)
            else {
                let e = NSError(domain: "payment", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed response"])
                DispatchQueue.main.async {
                    ctx.report(.LogStripeIntentFetchFailure, details.build(), e, progress)
                    completion(e, 0)
                }
                return
            }

            details.intentID = resp.intentId
            IntentFetchMessage.message = resp.error == nil ? resp.intentStatus.rawVal : (resp.error?.localizedDescription ?? "")

            if let e = resp.error {
                DispatchQueue.main.async {
                    ctx.report(.LogStripeIntentFetchFailure, details.build(), e, progress)
                    completion(e, resp.amount)
                }
                return
            }

            DispatchQueue.main.async {
                ctx.report(.LogStripeIntentFetchSuccess, details.build(), nil, progress)
            }

            if resp.confirmed {
                DispatchQueue.main.async {
                    ctx.report(.LogStripeIntentFlowCompleted, details.build(), nil, progress)
                }
                ctx.validateCard { vErr in
                    DispatchQueue.main.async { completion(vErr, resp.amount) }
                } _: { s, e in
                    ctx.report(s, details.build(), e, progress)
                }
            } else {
                ctx.displayIntent(ctx.config.viewController, resp, ctx.config.product.type) { dispErr in
                    DispatchQueue.main.async { completion(dispErr, resp.amount) }
                } _: { s, e in
                    DispatchQueue.main.async {
                        ctx.report(s, details.build(), e, progress)
                    }
                }
            }
        }
    }
}
