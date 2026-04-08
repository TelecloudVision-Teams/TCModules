//
//  File.swift
//  
//
//  Created by Ali on 28/06/2024.
//

import UIKit

protocol FirebaseAnalyticsProvider: AnalyticsProvider
{
    func logout()
    func login(userId: String)
}
// Provide default implementations for optional methods
extension FirebaseAnalyticsProvider {
    func application(app: UIApplication?, open: URL?, options: [UIApplication.OpenURLOptionsKey: Any]?) {}
    func applicationContinue(userActivity: NSUserActivity) {}
    func handlePushNotification(userInfo: [AnyHashable: Any]) {}
    func handleATTAuthorizationStatus(status: UInt) {}
}
