//
//  BranchProvider.swift
//  AnalyticsFramework
//
//  Created by Admin on 01/06/2022.
//

import Foundation
import BranchSDK

typealias EventCompletion = ((Bool, Error?)->Void)?

struct BranchProvider: BranchAnalyticsProvider
{
    var type: TCAnalyticsProvider = .Branch
    
    var maxRetries:Int = 1
    {
        didSet {
            Branch.getInstance().setMaxRetries(maxRetries)
        }
    }
    var retryInterval:TimeInterval = 1
    {
        didSet {
            Branch.getInstance().setRetryInterval(retryInterval)
        }
    }
    var networkTimeOut:TimeInterval = 6
    {
        didSet {
            Branch.getInstance().setNetworkTimeout(networkTimeOut)
        }
    }
    
    /// Initialize Branch
    /// Add in applicationDidFinishLaunching
    /// - Parameter launchOptions: launchOptions
    /// - Parameter completion: handler for result and error
    
    func initialize(launchOptions: [UIApplication.LaunchOptionsKey : Any]?, completion: @escaping ([String : AnyObject]?, (any Error)?) -> Void) {
        Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
            completion(params as? [String: AnyObject] ?? [:], error)
        }
    }
    
    func log(eventName: String, parameters: [String : Any]?, completion: EventCompletion) {
        if eventName.lowercased() == BranchStandardEvent.purchase.rawValue.lowercased(),
           let parameters = parameters,
           let purchase = parameters["purchase"] as? TCPurchase
        {
            log(purchase: purchase, completion: completion)
        }
        else
        {
            let event = BranchEvent.customEvent(withName: eventName)
            event.customData = parameters as? [String:String] ?? [:]
            event.logEvent(completion: completion)
        }
    }
    
    func log(purchase: TCPurchase, completion: EventCompletion) {
        let event = BranchEvent.standardEvent(.purchase)
        let branchUniversalObject = BranchUniversalObject.init()
        branchUniversalObject.title = purchase.title
        branchUniversalObject.canonicalIdentifier = purchase.productId
        branchUniversalObject.contentMetadata.productName = purchase.title
        branchUniversalObject.contentMetadata.quantity = 1
        branchUniversalObject.contentMetadata.customMetadata = NSMutableDictionary(dictionary: purchase.parameters)
        branchUniversalObject.contentMetadata.price = NSDecimalNumber(string: String(purchase.price))
        branchUniversalObject.contentMetadata.currency = .USD
        branchUniversalObject.contentMetadata.contentSchema = .commerceProduct
        event.contentItems = [ branchUniversalObject ]
        event.currency = .USD
        event.eventDescription = purchase.transactionId
        event.revenue = Decimal(purchase.price) as NSDecimalNumber
        event.logEvent(completion: completion)
    }
    
    /// Initialize Branch
    /// Add in applicationOptions
    /// - Parameter app: UIApplication
    /// - Parameter open: URL
    /// - Parameter options: [UIApplication.OpenURLOptionsKey : Any]
    func application(app: UIApplication?, open: URL?, options: [UIApplication.OpenURLOptionsKey: Any]?) {
        guard let urlString = open?.absoluteString else { return }
        
        if urlString.contains("link_click_id") || urlString.contains("app.link") || urlString.contains("branch") {
            checkPasteboardIfNeeded()
            Branch.getInstance().application(app, open: open, options: options)
        }
    }
    
    /// Initialize Branch
    /// Add in applicationUserActivity
    /// - Parameter userActivity: NSUserActivity
    func applicationContinue(userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL?.absoluteString else { return }
        
        if url.contains("app.link") || url.contains("branch") {
            checkPasteboardIfNeeded()
            Branch.getInstance().continue(userActivity)
        }
    }
    /// Initialize Branch
    /// Add in applicationDidReceiveRemoteNotification
    /// - Parameter userInfo: [AnyHashable : Any]
    func handlePushNotification(userInfo: [AnyHashable : Any]) {
        Branch.getInstance().handlePushNotification(userInfo)
    }
    
    /// After Branch sees the user opt-in via ATT
    /// Branch starts tracking an additional analytics event called “second install” for ad-driven installs
    func handleATTAuthorizationStatus(status:UInt)
    {
        Branch.getInstance().handleATTAuthorizationStatus(status)
    }
    
    /// Logs out user identity
    func logout()
    {
        Branch.getInstance().logout()
    }
    /// Logs in user identity
    func login(userId:String)
    {
        Branch.getInstance().setIdentity(userId)
    }
    private func checkPasteboardIfNeeded() {
        if #available(iOS 16.0, *) {
            // Do nothing to avoid triggering the paste popup
            return
        } else {
            // Safe to check on iOS 15 and below
            Branch.getInstance().checkPasteboardOnInstall()
        }
    }
}
