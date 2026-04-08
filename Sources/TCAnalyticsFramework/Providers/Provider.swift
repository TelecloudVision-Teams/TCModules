//
//  Provider.swift
//  AnalyticsFramework
//
//  Created by Admin on 01/06/2022.
//

import UIKit
import FirebaseCore

// Refactor the Provider struct
struct Provider {
    var analyticsProvider: AnalyticsProvider
    
    init(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, analyticsProvider: AnalyticsProvider, completion: @escaping ([String: AnyObject]?, Error?) -> Void) {
        self.analyticsProvider = analyticsProvider
        analyticsProvider.initialize(launchOptions: launchOptions, completion: completion)
    }
    
    func application(app: UIApplication?, open: URL?, options: [UIApplication.OpenURLOptionsKey: Any]?) {
        analyticsProvider.application(app: app, open: open, options: options)
    }
    
    func applicationContinue(userActivity: NSUserActivity) {
        analyticsProvider.applicationContinue(userActivity: userActivity)
    }
    
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        analyticsProvider.handlePushNotification(userInfo: userInfo)
    }
    
    func handleATTAuthorizationStatus(status: UInt) {
        analyticsProvider.handleATTAuthorizationStatus(status: status)
    }
    
    func logout() {
        analyticsProvider.logout()
    }
    
    func login(userId: String) {
        analyticsProvider.login(userId: userId)
    }
    
    func log(eventName: String, parameters: [String: Any]? = nil, completion: EventCompletion = nil) {
        analyticsProvider.log(eventName: eventName, parameters: parameters, completion: completion)
    }
    
    func log(purchase: TCPurchase, completion: EventCompletion = nil) {
        analyticsProvider.log(purchase: purchase, completion: completion)
    }
    func setMaxRetries(value:Int)
    {
        if var branchProvider = analyticsProvider as? BranchAnalyticsProvider {
            branchProvider.maxRetries = value
        }
    }
    func setRetryInterval(value:TimeInterval)
    {
        if var branchProvider = analyticsProvider as? BranchAnalyticsProvider {
            branchProvider.retryInterval = value
        }
    }
    func setNetworkTimeout(value:TimeInterval)
    {
        if var branchProvider = analyticsProvider as? BranchAnalyticsProvider {
            branchProvider.networkTimeOut = value
        }
    }
}
