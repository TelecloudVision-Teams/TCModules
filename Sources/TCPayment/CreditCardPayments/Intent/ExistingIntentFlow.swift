//
//  ExistingIntentFlow.swift
//  TCPayment
//
//  Created by Ali on 22/10/2025.
//

import UIKit
import TCSharedFramework

final class ExistingIntentFlow: PurchaseFlow {
    func start(ctx: PurchaseContext,
               completion: @escaping (Error?, Double) -> Void,
               progress: @escaping (PaymentProgress) -> Void)
    {
        guard let intentConfig = ctx.config.intentConfig
        else {
            let e = NSError(domain: "payment", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing intentId"])
            completion(e, 0)
            return
        }

        var details = ctx.intentDetails
        details.intentID = intentConfig.intentId
        details.appLanguage = TCPayment.language.localeIdentifier
        details.productId = ctx.config.product.id
        details.appLanguage = TCPayment.language.localeIdentifier
        details.rechargeProductType = ctx.config.product.type.description
        details.professionalId = ctx.config.preferences.professionalId

        DispatchQueue.main.async {
            ctx.report(.LogStripeIntentFetchSuccess, details.build(), nil, progress)
        }

        IntentFetchMessage.message = intentConfig.error == nil ? intentConfig.intentStatus.rawVal : (intentConfig.error?.localizedDescription ?? "")

        if let e = intentConfig.error {
            DispatchQueue.main.async {
                ctx.report(.LogStripeIntentFetchFailure, details.build(), e, progress)
                completion(e, intentConfig.amount)
            }
            return
        }

        DispatchQueue.main.async {
            ctx.report(.LogStripeIntentFetchSuccess, details.build(), nil, progress)
        }

        ctx.displayIntent(ctx.config.viewController, intentConfig, ctx.config.product.type) { dispErr in
            DispatchQueue.main.async { completion(dispErr, intentConfig.amount) }
        } _: { s, e in
            DispatchQueue.main.async {
                ctx.report(s, details.build(), e, progress)
            }
        }
    }
}
