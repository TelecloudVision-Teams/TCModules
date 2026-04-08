//
//  File.swift
//  
//
//  Created by Ali on 28/06/2024.
//

import UIKit

// Define specialized protocols for Branch if needed
protocol BranchAnalyticsProvider: AnalyticsProvider {
    var maxRetries:Int { set get }
    var retryInterval:TimeInterval { set get }
    var networkTimeOut:TimeInterval { set get }
    
    func application(app: UIApplication?, open: URL?, options: [UIApplication.OpenURLOptionsKey: Any]?)
    func applicationContinue(userActivity: NSUserActivity)
    func handlePushNotification(userInfo: [AnyHashable: Any])
    func handleATTAuthorizationStatus(status: UInt)
}
