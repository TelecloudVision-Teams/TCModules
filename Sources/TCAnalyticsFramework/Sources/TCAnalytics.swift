//
//  Analytics.swift
//  AnalyticsFramework
//
//  Created by Admin on 01/06/2022.
//

import TCSharedFramework
import UIKit

@objc public protocol TCAnalyticsDelegate
{
    @objc func TCAnalyticsDidReceiveDeepLinkData(data:[String: AnyObject]?, error: Error?)
}
@objcMembers public class TCAnalytics: NSObject {
    private static let shared = TCAnalytics()
    private var request = AnalyticsRequest()
    private var launchOptions:[UIApplication.LaunchOptionsKey: Any]?
    
    public var delegate:TCAnalyticsDelegate?
    public static var configuration: TCAnalyticsConfiguration = {
        let config = TCAnalyticsConfiguration()
        shared.bindConfiguration(config)
        return config
    }()
    private func bindConfiguration(_ config: TCAnalyticsConfiguration) {
        // whenever config changes, propagate to the request
        config.onChange = { [weak self] updated in
            guard let self = self else { return }
            self.request.userId = updated.userId
            if let lang = updated.language
            {
                self.request.language = lang
            }
            self.request.maxRetries   = updated.maxRetries
            self.request.retryInterval = updated.retryInterval
            self.request.networkTimeOut = updated.networkTimeout
            // uuid & environment can be sent along with each event as needed
        }
        // initialize request with the defaults
        config.onChange?(config)
    }
    
    
    @objc public static func initSDKWithLaunchOptions(launchOptions: [UIApplication.LaunchOptionsKey: Any]?,
                                                      delegate:TCAnalyticsDelegate)
    {
        shared.launchOptions = launchOptions
        shared.delegate = delegate
    }
    
    /// Register providers in didFinishLaunchingWithOptions
    /// - Parameter provider: ProviderType
    /// - Parameter Key: initialize key for the provider
    @objc public static func register(provider: TCAnalyticsProvider) {
        
        let prov = Provider(launchOptions: shared.launchOptions, analyticsProvider: provider.type) { data, error in
            shared.delegate?.TCAnalyticsDidReceiveDeepLinkData(data: data, error: error)
        }
        shared.request.add(provider:prov)
    }
    
    /// Add in applicationOptions
    /// - Parameter app: UIApplication
    /// - Parameter open: URL
    /// - Parameter options: [UIApplication.OpenURLOptionsKey : Any]
    @objc public static func application(app: UIApplication?,open:URL?,options: [UIApplication.OpenURLOptionsKey : Any]?) {
        shared.request.application(app: app, open: open, options: options)
    }
    
    /// Add in applicationUserActivity
    /// - Parameter userActivity: NSUserActivity
    @objc public static func applicationContinue(userActivity: NSUserActivity) {
        shared.request.applicationContinue(userActivity: userActivity)
        
    }
    
    /// Add in applicationDidReceiveRemoteNotification
    /// - Parameter userInfo: [AnyHashable : Any]
    @objc public static func handlePushNotification(userInfo: [AnyHashable : Any]) {
        shared.request.handlePushNotification(userInfo: userInfo)
    }
    
    /// Call after requesting ATTAuthorization framework API
    @objc public static func handleATTAuthorizationStatus(status:UInt)
    {
        shared.request.handleATTAuthorizationStatus(status: status)
    }
    
    /// Log the events
    /// - Parameter eventName: Event Name
    /// - Parameter provider: Event provider
    /// - Parameter parameters: Event parameters
    @objc public static func log(for eventName:String, parameters: [String:Any]) {
        shared.request.log(for: eventName, parameters: parameters)
    }
    
    /// Log the events
    /// - Parameter eventName: Event Name
    @objc public static func log(for eventName:String) {
        shared.request.log(for: eventName)
    }
    
    /// Initialize the reporter that will report purchase logs to backend and MP
    @objc public static func registerTransactionLogger(guid:String, primaryDNS:String, secondaryDNS:String?, MPEndpoint: String, backendEndpoint: String)
    {
        shared.request.AppGUID = guid
        shared.request.url = TCEndpoint(primaryDNS: primaryDNS, secondaryDNS: secondaryDNS, MPEndpoint: MPEndpoint, backendEndpoint: backendEndpoint)
    }
    
    /// Log non-iTunes events to backend and MP
    @objc public static func logWallet(event:MinutesStoreEvent,
                                       professionalId:String,
                                       type:PurchaseItemType,
                                       product:String,
                                       purchaseTitle:String,
                                       error:Error?,
                                       errorHandler: ((_ error:Error?) -> Void)?)
    {
        shared.request.professional = professionalId
        shared.request.type = type
        shared.request.log(event: event, product: product, cost: 0, purchaseTitle:purchaseTitle, error: error, errorHandler: errorHandler)
    }
    @objc public static func log(event:TCPaymentTransactionState,
                                 professionalId:String,
                                 type:PurchaseItemType,
                                 cost:Double,
                                 purchaseTitle:String,
                                 intentResult:IntentPurchaseDetails,
                                 error:Error?,
                                 errorHandler: ((_ error:Error?) -> Void)?)
    {
        shared.request.professional = professionalId
        log(event: event, type: type, cost: cost, purchaseTitle:purchaseTitle, intentResult: intentResult, error: error, errorHandler: errorHandler)
    }
    @objc public static func log(event:TCPaymentTransactionState,
                                 type:PurchaseItemType,
                                 cost:Double,
                                 purchaseTitle:String,
                                 intentResult:IntentPurchaseDetails,
                                 error:Error?,
                                 errorHandler: ((_ error:Error?) -> Void)?)
    {
        shared.request.type = type
        shared.request.log(event: event, cost: cost, purchaseTitle:purchaseTitle, intentResult: intentResult, error: error, errorHandler: errorHandler)
    }
    
    /// Log iTunes Purchase events
    @objc public static func log(event:TCPaymentTransactionState,
                                 cost:Double,
                                 purchaseTitle:String,
                                 result:PurchaseDetails,
                                 error:Error?,
                                 errorHandler: ((_ error:Error?) -> Void)?)
    {
        if let storeId = result.transaction?.storeId,
           let storeFront = result.transaction?.storeCountry,
           let storefrontPrice = result.transaction?.storePrice,
           let storefrontCurrency = result.transaction?.storeCurrency,
           let type = result.transaction?.notificationType
        {
            shared.request.storeInfo = SKStoreInfo(storefront: storeFront,
                                                   storefrontId: storeId,
                                                   storefrontPrice: storefrontPrice,
                                                   storefrontCurrency: storefrontCurrency,
                                                   notificationType: type)
        }
        shared.request.type = .iAP
        shared.request.log(event: event, cost:cost, purchaseTitle:purchaseTitle, result: result, error: error, errorHandler: errorHandler)
    }
}
