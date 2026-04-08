//
//  File.swift
//  
//
//  Created by Ali on 28/06/2024.
//

import UIKit

protocol AnalyticsProvider {
    var type:TCAnalyticsProvider { get }
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey: Any]?, completion: @escaping ([String: AnyObject]?, Error?) -> Void)
    func log(eventName: String, parameters: [String: Any]?, completion: EventCompletion)
    func log(purchase: TCPurchase, completion: EventCompletion)
    func application(app: UIApplication?, open: URL?, options: [UIApplication.OpenURLOptionsKey: Any]?)
    func applicationContinue(userActivity: NSUserActivity)
    func handlePushNotification(userInfo: [AnyHashable: Any])
    func handleATTAuthorizationStatus(status: UInt)
    func logout()
    func login(userId: String)
}
