//
//  File.swift
//  
//
//  Created by Telecloud on 04/06/2024.
//

import UIKit

@objcMembers
public class IntentPurchaseDetails: NSObject {
    public let productId: String
    public let intentID: String?
    public let bundleName: String
    public let receiptDataBase64: String
    public let receiptDataBase64Original: String
    public let appLanguage: String
    public let platformVersion: String
    public let deviceIdentifier: String
    public let rechargeProductType: String
    public let professionalId: String?

    // Private designated initializer: only the builder can call this.
    fileprivate init(productId: String,
                     intentID: String?,
                     bundleName: String,
                     receiptDataBase64: String,
                     receiptDataBase64Original: String,
                     appLanguage: String,
                     platformVersion: String,
                     deviceIdentifier: String,
                     rechargeProductType: String,
                     professionalId: String?) {
        self.productId = productId
        self.intentID = intentID
        self.bundleName = bundleName
        self.receiptDataBase64 = receiptDataBase64
        self.receiptDataBase64Original = receiptDataBase64Original
        self.appLanguage = appLanguage
        self.platformVersion = platformVersion
        self.deviceIdentifier = deviceIdentifier
        self.rechargeProductType = rechargeProductType
        self.professionalId = professionalId
    }
}
@objcMembers
public class IntentPurchaseDetailsBuilder: NSObject {
    public var productId: String?
    public var intentID: String?
    public var bundleName: String = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
    public var receiptDataBase64: String = ""
    public var receiptDataBase64Original: String = ""
    public var appLanguage: String = "ar"
    public var platformVersion: String = UIDevice.current.systemVersion
    public var deviceIdentifier: String = UIDevice.deviceIdentifier.value ?? ""
    public var rechargeProductType: String?
    public var professionalId: String?
    
    public override init() {
        super.init()
    }
    
    public func build() -> IntentPurchaseDetails? {
        guard let productId = productId,
              let rechargeProductType = rechargeProductType
              else {
            return nil
        }
        return IntentPurchaseDetails(productId: productId,
                                     intentID: intentID,
                                     bundleName: bundleName,
                                     receiptDataBase64: receiptDataBase64,
                                     receiptDataBase64Original: receiptDataBase64Original,
                                     appLanguage: appLanguage,
                                     platformVersion: platformVersion,
                                     deviceIdentifier: deviceIdentifier,
                                     rechargeProductType: rechargeProductType,
                                     professionalId: professionalId)
    }
}
