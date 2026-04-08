//
//  FirebaseProvider.swift
//  AnalyticsFramework
//
//  Created by Admin on 01/06/2022.
//

import Foundation
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics

struct FirebaseProvider: FirebaseAnalyticsProvider {
    var type: TCAnalyticsProvider = .Branch
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, completion: @escaping ([String: AnyObject]?, Error?) -> Void) {
        FirebaseApp.configure()
        completion(nil,nil)
    }
    
    func log(eventName: String, parameters: [String: Any]?, completion: EventCompletion) {
        Analytics.logEvent(eventName, parameters: parameters)
        completion?(true, nil)
    }
    
    func log(purchase: TCPurchase, completion: EventCompletion) {
        let purchaseParams: [String: Any] = [
            AnalyticsParameterItemName: purchase.title,
            AnalyticsParameterItemID: purchase.productId,
            AnalyticsParameterPrice: purchase.price,
            AnalyticsParameterQuantity: 1,
            AnalyticsParameterTransactionID: purchase.transactionId,
            AnalyticsParameterCurrency: "USD",
            AnalyticsParameterValue: purchase.price,
        ]
        let params = purchaseParams.merging(purchase.parameters) { $1 }
        Analytics.logEvent(AnalyticsEventPurchase, parameters: params)
        completion?(true, nil)
    }
    
    /// Logs out user identity
    func logout()
    {
        Analytics.setUserID(nil)
        Crashlytics.crashlytics().setUserID(nil)
    }
    /// Logs in user identity
    func login(userId:String)
    {
        Analytics.setUserID(userId)
        Crashlytics.crashlytics().setUserID(userId)
    }
}
