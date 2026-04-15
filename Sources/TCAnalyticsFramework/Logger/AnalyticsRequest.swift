//
//  AnalyticsReporter.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import UIKit
import TCNetwork
import TCSharedFramework
import FirebaseAnalytics
import StoreKit
import TCLocationFramework

class AnalyticsRequest:NSObject
{
    private var guid:String = UUID().uuidString
    private var productId = ""
    private var purchaseTitle = ""
    private var cost:Double = 0
    private var deviceInfo:DeviceInfo?
    private var currentBackendURL:String?
    private var currentMPURL:String?
    private var backendMaxRetry = 5
    private var providers: [Provider] = []
    
    var type:PurchaseItemType = .iAP
    {
        didSet {
            professional = ""
        }
    }
    var storeInfo:SKStoreInfo?
    var professional = ""
    var language:TCLanguage = .arabic
    var AppGUID:String?
    {
        didSet {
            deviceInfo = DeviceInfo(guid: AppGUID!)
        }
    }
    var userId:String?
    {
        didSet {
            if let userId = userId,
               !userId.isEmpty
            {
                providers.forEach({ $0.login(userId: userId)})
            }
            else
            {
                providers.forEach({ $0.logout()})
            }
        }
    }
    var url:TCEndpoint? {
        didSet {
            currentBackendURL = url?.backEndFullPath()
            currentMPURL = url?.MPFullPath()
        }
    }
    public var maxRetries:Int = 1
    {
        didSet {
            providers.forEach({ $0.setMaxRetries(value: maxRetries) })
        }
    }
    public var retryInterval:TimeInterval = 1
    {
        didSet {
            providers.forEach({ $0.setRetryInterval(value: retryInterval) })
        }
    }
    public var networkTimeOut:TimeInterval = 6
    {
        didSet {
            providers.forEach({ $0.setNetworkTimeout(value: networkTimeOut) })
        }
    }
    
    override init()
    {
        super.init()
    }
    func add(provider:Provider)
    {
        providers.append(provider)
    }
    private func reset()
    {
        guid = UUID().uuidString
        productId = ""
        cost = 0
        storeInfo = nil
    }
    // Parameters for Stripe
    private func createParams() -> [String:Any]
    {
        var params:[String:Any] = [
            "BundleName":Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "",
            "ReceiptDataBase64":"",
            "ReceiptDataBase64Original":"",
            "AppLanguage":language.string,
            "PlatformVersion":UIDevice.current.systemVersion,
            "DeviceIdentifier":UIDevice.deviceIdentifier.value ?? "",
            "ProductTypeId":5
        ]
        if let info = SKStoreInfo.empty.toDictionary()
        {
            params.merge(info, uniquingKeysWith: { (_, new) in new })
        }
        return params
    }
    
    func log(event:MinutesStoreEvent,
             product:String,
             cost:Double,
             purchaseTitle:String,
             error:Error?,
             errorHandler: ((_ error:Error?) -> Void)?,
             completion:EventCompletion = nil)
    {
        if event == .clicked { reset() }
        productId = product
        self.purchaseTitle = purchaseTitle
        self.cost = cost
        logBackend(parameters:createParams(), orderId: "", transactionId: "", state: event.description(type: type), error: error)
        if event == .success
        {
            sendLog(transactionStatus: TransactionStatus.success.rawValue,
                    paymentGateway: PaymentGateway.other,
                    orderId: "",
                    transactionId: "",
                    error: error,
                    errorHandler: errorHandler)
            logCustomPurchaseEvent()
            let purchase = TCPurchase(title:purchaseTitle,
                                      price: cost,
                                      productId: productId,
                                      language: language,
                                      transactionId: "",
                                      userId: userId ?? "N/A")
            log(purchase: purchase, completion: completion)
        }
        else if event == .failed
        {
            sendLog(transactionStatus: TransactionStatus.failed.rawValue,
                    paymentGateway: PaymentGateway.other,
                    orderId: "",
                    transactionId: "",
                    error: error,
                    errorHandler: errorHandler)
        }
    }
    func log(event:TCPaymentTransactionState,
             cost:Double,
             purchaseTitle:String,
             intentResult:IntentPurchaseDetails,
             error:Error?,
             errorHandler: ((_ error:Error?) -> Void)?,
             completion:EventCompletion = nil)
    {
        switch event {
        case .LogIAPClickPurchase,
                .LogStripeIntentPurchaseStarted:
            reset()
        default:
            break
        }
        let orderId = fetchOrderId(intent: intentResult)
        productId = intentResult.productId
        self.cost = cost
        self.purchaseTitle = purchaseTitle
        logBackend(parameters:createParams(), orderId: orderId, transactionId: "", state: event.value(), error: error)
        logMP(status: event, paymentGateway: .other, orderId: orderId, transactionId: "", error: error, errorHandler: errorHandler, completion: completion)
    }
    func log(event:TCPaymentTransactionState,
             cost:Double,
             purchaseTitle:String,
             result:PurchaseDetails,
             error:Error?,
             errorHandler: ((_ error:Error?) -> Void)?,
             completion:EventCompletion = nil)
    {
        self.cost = cost
        self.purchaseTitle = purchaseTitle
        switch event {
        case .LogIAPClickPurchase,
                .LogSubscriptionClickPurchase,
                .LogSubscriptionRestoreClickPurchase,
                .LogStripeIntentPurchaseStarted:
            reset()
        default:
            break
        }
        
        productId = result.productId
        let transactionId = result.transaction?.transactionID ?? ""
        let orderId = fetchOrderId(purchase: result)
        let params: [String:Any] = result.dictionary
        logBackend(parameters: params, orderId: orderId,transactionId: transactionId, state: event.value(), error: error, errorHandler: errorHandler)
        logMP(status: event, paymentGateway: .iAP, orderId: orderId, transactionId:transactionId, error: error, errorHandler: errorHandler, completion: completion)
    }
    private func fetchOrderId(intent:IntentPurchaseDetails? = nil, purchase:PurchaseDetails? = nil) -> String {
        if let intent = intent {
            return intent.intentID ?? ""
        }
        else if let purchase = purchase
        {
            return purchase.transaction?.webOrderLineItemID ?? purchase.transaction?.transactionID ?? ""
        }
        return ""
    }
    private func logBackend(retries:Int = 0,
                            delayIncrease:Double = 3,
                            parameters:[String:Any] = [:],
                            orderId:String,
                            transactionId:String,
                            state:String,
                            error:Error?,
                            errorHandler: ((_ error:Error?) -> Void)? = nil)
    {
        guard let urlString = currentBackendURL else {
            fatalError("URL not set")
        }
        
        var params = parameters
        params["ProductId"] = productId
        params["TransRef"] = guid
        params["UserObj"] = userId ?? "unknown"
        params["PlatformTypeId"] = 1
        params["OrderId"] = orderId
        params["Token"] = ""
        params["Description"] = state
        params["environment"] = TCAnalytics.configuration.environment.stringValue
        params["appAccountToken"] = TCAnalytics.configuration.uuid
        params["iOSTransactionId"] = transactionId

        if let tokenParams = TCNetwork.shared.token?.params
        {
            params.merge(tokenParams, uniquingKeysWith: { (_, new) in new })
        }
        
        if let error = error
        {
            params["Error"] = "\(error)"
        }
        else
        {
            params["Error"] = params["Error"] != nil ? params["Error"] : ""
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        {
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, responseError) in
                guard let self = self else { return }
                if let data = data,
                   let string = String(data: data, encoding: .utf8)
                {
                    print("Response: \(string)")
                }
                if let responseError = responseError {
                    let errorString = "Purchase Error DNS: \(urlString)\n MP Error: \(responseError)"
                    let err = NSError(domain: errorString, code: responseError._code)
                    if let secondary = self.url?.backEndFullPath(switchDNS: true),
                       secondary != self.currentBackendURL
                    {
                        self.currentBackendURL = secondary
                    }
                    else { self.currentBackendURL = self.url?.backEndFullPath() }
                    Log.e(error: err)
                    errorHandler?(err)
                    if retries < self.backendMaxRetry {
                        let retryDelay = (Double(retries) + 1) * delayIncrease
                        Log.d("Retrying in \(retryDelay) seconds...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                            self.logBackend(retries:retries+1,
                                            orderId: orderId,
                                            transactionId: transactionId,
                                            state: state,
                                            error: error,
                                            errorHandler: errorHandler)
                        }
                    }
                    else
                    {
                        self.logBackend(orderId: orderId,
                                        transactionId: transactionId,
                                        state: state,
                                        error: error,
                                        errorHandler: errorHandler)
                    }
                }
            }.resume()
        }
    }
    private func logMP(status:TCPaymentTransactionState,
                       paymentGateway: PaymentGateway,
                       orderId:String,
                       transactionId:String,
                       error:Error?,
                       errorHandler: ((_ error:Error?) -> Void)?,
                       completion:EventCompletion)
    {
        switch status {
        case .LogSubscriptionFailedPurchaseAfterSendingData,
                .LogIAPFailedPurchaseAfterSendingData,
                .LogIAPSuccessPurchaseAfterSendingData,
                .LogSubscriptionSuccessPurchaseAfterSendingData,
                .LogStripeIntentFlowCompleted:
            break
        default:
            return
        }
        
        var transactionStatus = ""
        let transaction = transactionId.isEmpty ? orderId : transactionId
        let purchase = TCPurchase(title:purchaseTitle,
                                  price: cost,
                                  productId: productId,
                                  language: language,
                                  transactionId: transaction,
                                  userId: userId)
        if paymentGateway == .iAP
        {
            if status == .LogIAPSuccessPurchaseAfterSendingData || status == .LogSubscriptionSuccessPurchaseAfterSendingData {
                logCustomPurchaseEvent()
                log(provider: .Branch, purchase: purchase, completion: completion)
                transactionStatus = TransactionStatus.success.rawValue
            }
            else if status == .LogIAPFailedPurchaseAfterSendingData { transactionStatus = TransactionStatus.failed.rawValue }
            else { return }
        }
        else
        {
            if status == .LogStripeIntentFlowCompleted {
                logCustomPurchaseEvent()
                log(purchase: purchase, completion: completion)
                transactionStatus = TransactionStatus.success.rawValue
            }
            else { return }
        }
        sendLog(transactionStatus: transactionStatus,
                paymentGateway: paymentGateway,
                orderId: orderId,
                transactionId: transactionId,
                error: error,
                errorHandler: errorHandler)
    }
    
    private func sendLog(retries:Int = 0,
                         delayIncrease:Double = 3,
                         transactionStatus:String,
                         paymentGateway:PaymentGateway,
                         orderId:String,
                         transactionId:String,
                         error:Error?,
                         errorHandler: ((_ error:Error?) -> Void)? = nil)
    {
        guard let urlString = currentMPURL else {
            fatalError("URL not set")
        }
        guard let deviceInfo = deviceInfo else {
            fatalError("Guid not set")
        }
        let productTypeId:Int
        if paymentGateway == .iAP {
            if productId.contains("subscri")
            {
                productTypeId = 3
            }
            else
            {
                productTypeId = 1
            }
        }
        else
        {
            productTypeId = 5
        }
        let analytics = AnalyticsTransactionLog(deviceInfo: deviceInfo,
                                                productId: productId,
                                                transactionId: transactionId,
                                                orderId: orderId,
                                                cost: cost,
                                                productTypeId: productTypeId,
                                                language: language,
                                                transactionStatus: transactionStatus,
                                                userId: userId,
                                                error: error,
                                                storeInfo: storeInfo)
        
        guard let params = analytics.toDictionary() else { return }
        if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions.prettyPrinted)
        {
            let url = URL(string: urlString)!
            var request = URLRequest(url: url)
            request.setValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { [weak self] (data, response, responseError) in
                guard let self = self else { return }
                if let responseError = responseError {
                    let errorString = "Purchase Error DNS: \(urlString)\n MP Error: \(responseError)"
                    let err = NSError(domain: errorString, code: responseError._code)
                    errorHandler?(err)
                    
                    if let secondary = self.url?.MPFullPath(switchDNS: true),
                       secondary != self.currentMPURL
                    {
                        self.currentMPURL = secondary
                    }
                    else { self.currentMPURL = self.url?.MPFullPath() }
                    Log.e(error: err)
                    errorHandler?(err)
                    if retries < self.maxRetries {
                        let retryDelay = (Double(retries) + 1) * delayIncrease
                        Log.d("Retrying in \(retryDelay) seconds...")
                        DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) {
                            self.sendLog(retries:retries+1,
                                         transactionStatus: transactionStatus,
                                         paymentGateway: paymentGateway,
                                         orderId: orderId,
                                         transactionId: transactionId,
                                         error: error,
                                         errorHandler: errorHandler)
                        }
                    }
                    else
                    {
                        self.sendLog(transactionStatus: transactionStatus,
                                     paymentGateway: paymentGateway,
                                     orderId: orderId,
                                     transactionId: transactionId,
                                     error: error,
                                     errorHandler: errorHandler)
                    }
                    
                }
                else if let data = data
                {
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("✅ JSON Response:", json)
                    } else if let string = String(data: data, encoding: .utf8) {
                        print("📝 Raw Response String:", string)
                    } else {
                        print("❓ Received data could not be parsed")
                    }

                }
            }.resume()
        }
    }
    
    private func fetchParams() -> [String:Any]
    {
        var params:[String:Any] = [
            "value":cost,
            "currency":"USD",
            "transaction_id":guid,
            "ID":productId,
            "AppLanguage":language.string
        ]
        if professional.count > 0
        {
            params["Consultant"] = professional
        }
        return params
    }
    /// Log the custom purchase events
    private func logCustomPurchaseEvent()
    {
        let params = fetchParams()
        
        var eventName = ""
        switch type {
        case .iAP:
            eventName = productId.contains("subs") ? "PURCHASE_TAMAYAZ" : "PURCHASE_\(Int(round(cost)))"
        case .voice:
            eventName = "Purchase_Time_Voice"
        case .video:
            eventName = "Purchase_Time_Video"
        }
        log(for: eventName, parameters: params, provider: .Firebase)
    }
    
    /// Log the events
    /// - Parameter eventName: Event Name
    /// - Parameter parameters: Event parameters
    func log(for eventName:String, parameters: [String:Any]? = nil, completion:EventCompletion = nil) {
        for provider in self.providers {
            provider.log(eventName: eventName, parameters: parameters, completion: completion)
        }
    }
    
    private func log(provider:TCAnalyticsProvider? = nil, purchase:TCPurchase, completion:EventCompletion)
    {
        if purchase.price == 0 || purchase.transactionId.isEmpty { return }
        if let provider = provider
        {
            let prov = providers.filter { $0.analyticsProvider.type == provider }.first
            prov?.log(purchase: purchase, completion: completion)
        }
        else
        {
            for prov in providers
            {
                prov.log(purchase: purchase, completion: completion)
            }
        }
    }
    func log(for eventName:String, parameters: [String:Any]? = nil, provider:TCAnalyticsProvider, completion:EventCompletion = nil)
    {
        let prov = providers.filter { $0.analyticsProvider.type == provider }.first
        prov?.log(eventName: eventName, parameters: parameters, completion: completion)
    }
    
    func handlePushNotification(userInfo: [AnyHashable : Any])
    {
        providers.forEach {
            $0.handlePushNotification(userInfo: userInfo)
        }
    }
    func applicationContinue(userActivity: NSUserActivity) {
        providers.forEach {
            $0.applicationContinue(userActivity: userActivity)
        }
    }
    func handleATTAuthorizationStatus(status:UInt)
    {
        providers.forEach {
            $0.handleATTAuthorizationStatus(status: status)
        }
    }
    func application(app: UIApplication?,open:URL?,options: [UIApplication.OpenURLOptionsKey : Any]?) {
        providers.forEach {
            $0.application(app: app, open: open, options: options)
        }
    }
}
