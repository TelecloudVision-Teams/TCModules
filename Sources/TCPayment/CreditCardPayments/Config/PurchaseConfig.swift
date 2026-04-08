//
//  CreditCardPurchaseConfig.swift
//  TCPayment
//
//  Created by Ali on 07/04/2025.
//

import UIKit

@objcMembers
public class PurchaseConfig: NSObject {
    public let viewController: UIViewController
    public let preferences: UserPreferences
    public var product: ProductInfo
    public var intentConfig:PaymentIntentResponse?
    
    @objc convenience public init(viewController: UIViewController,
                                  product: ProductInfo,
                                  preferences: UserPreferences)
    {
        self.init(viewController: viewController,
                  product: product,
                  preferences: preferences,
                  intentConfig: nil)
    }
    
    @objc public init(viewController: UIViewController,
                      product: ProductInfo,
                      preferences: UserPreferences,
                      intentConfig:PaymentIntentResponse? = nil) {
        self.viewController = viewController
        self.product = product
        self.preferences = preferences
        self.intentConfig = intentConfig
    }
    var apiVals: [String: Any] {
        var parm: [String: Any] = [
            "packageName": Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "",
            "rechargeProductType": product.type.description,
            "rechargeProductId": product.id,
            "professionalId": preferences.professionalId ?? "",
            "platform": "IOS",
            "appLanguage": TCPayment.language.localeIdentifier,
            "deviceIdentifier": TCPayment.deviceIdentifier
        ]
        
        if let saveCard = preferences.saveCard {
            parm["saveForFutureUse"] = saveCard
        }
        
        if let attemptAutoTopup = preferences.attemptAutoTopup {
            parm["attemptAutoTopUp"] = attemptAutoTopup
        }
        
        return parm
    }
}
