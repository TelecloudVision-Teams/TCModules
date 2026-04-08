import TCPaymentValidation
import ParseCore
import TCSharedFramework

public typealias PurchaseResultAlias = ((_ error:Error?,_ amount: Double)->())?
public typealias PurchaseProductIAPProgress = ((_ state:TCPaymentTransactionState,_ error:Error?,_ purchaseDetails: PurchaseDetails?)->())?

@objcMembers public class TCPayment: NSObject {
    
    internal var creditCard:CreditCard?
    
    // MARK: Singleton
    internal static let sharedInstance = TCPayment()
    public static let wcf = WCF()
    
    public static var language:TCPaymentLanguage = .arabic
    public static var sandBox:Bool = false
    public static var transactionUpdatesEnabled:Bool = true
    public static var paymentValidator:PaymentValidator = .parse
    public static var userID:String = ""
    public static var deviceIdentifier:String = ""
    public static var creditCardKey:String?
    private var hasStartedUpdates = false
    
    init(config: PurchaseConfig? = nil) {
        if let config = config{
            creditCard = CreditCard(config: config)
        }
    }
    // productId contains alwasy subscrib
    //enum // sub or consu
    
    internal class func stringContainsSubscrip(string:String) -> Bool{
        return string.lowercased().contains("subscri")
    }
    
    /// Retrieve products information
    /// - Parameter productIds: The set of product identifiers to retrieve corresponding products for
    /// - Parameter completion: handler for result
    /// - returns: A cancellable `InAppRequest` object
    ///
    public class func retrieveProductsInfo(_ productIds: Set<String>, completion: @escaping ((_ results: [Product]?, _ error: Error?) -> Void)) {
        ProductManager.fetchInformation(productIds) { results, error in
            completion(results, error)
        }
    }
    /// Purchase a product
    ///  - Parameter productId: productId as specified in App Store Connect
    ///  - Parameter quantity: quantity of the product to be purchased
    ///  - Parameter atomically: whether the product is purchased atomically (e.g. `finishTransaction` is called immediately)
    ///  - Parameter applicationUsername: an opaque identifier for the user’s account on your system
    ///  - Parameter completion: handler for result
    ///  - returns: A cancellable `InAppRequest` object
    
    // return amount
    
    public class func purchaseProductIAP(productId: String,
                                         completion: PurchaseResultAlias,
                                         progress: PurchaseProductIAPProgress) {
                
        let isSubscription = stringContainsSubscrip(string: productId)
        let purchase = PurchaseDetails(productId: productId, appLanguage: language.localeIdentifier)
        
        DispatchQueue.main.async {
            progress?(!isSubscription ? .LogIAPClickPurchase : .LogSubscriptionClickPurchase, nil, purchase)
        }
        
        TCPayment.retrieveProductsInfo(Set([productId])) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    progress?(.LogIAPRetrieveProductsInfoFailed, error, purchase)
                    completion?(error, 0)
                }
                return
            }

            guard let product = result?.first else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    progress?(.LogIAPRetrieveProductsInfoFailed, error, purchase)
                    completion?(error, 0)
                }
                return
            }

            DispatchQueue.main.async {
                progress?(.LogIAPRetrieveProductsInfoSuccess, nil, purchase)
            }

            TransactionContextManager.shared.begin(
                productID: product.id,
                completion: completion,
                progress: progress
            )

            Task {
                await PurchaseManager.purchase(product: product, completion:completion, progress: progress)
            }
        }
    }
    
    /// Restore purchases
    ///  - Parameter atomically: whether the product is purchased atomically (e.g. `finishTransaction` is called immediately)
    ///  - Parameter applicationUsername: an opaque identifier for the user’s account on your system
    ///  - Parameter completion: handler for result
    @objc public class func restorePurchases(subscriptionId: String,
                                             completion: @escaping (_ error: Error?) -> (),
                                             progress: PurchaseProductIAPProgress)
    {
        let purchase = PurchaseDetails(productId: subscriptionId, appLanguage: language.localeIdentifier)
        DispatchQueue.main.async {
            progress?(.LogSubscriptionRestoreClickPurchase,nil,purchase)
        }
        Task {
            await PurchaseManager.restorePurchases(completion: completion) { state, error, purchaseDetails in
                DispatchQueue.main.async {
                    progress?(state,error,purchaseDetails ?? purchase)
                }
            }
        }
    }
    
    /// Called on app launch to check active entitlements
    @objc public class func fetchCurrentTransactions(progress: PurchaseProductIAPProgress) {
        Task {
            await TransactionManager.trackTransactionUpdate(
                sequence: Transaction.currentEntitlements,
                completion: { _, _ in },
                progress: progress
            )
        }
    }
    private class func fetchUnfinishedTransactions(progress: PurchaseProductIAPProgress) {
        Task {
            await TransactionManager.trackTransactionUpdate(
                sequence: Transaction.unfinished,
                completion: { _, _ in },
                progress: progress
            )
        }
    }
    
    /// Called when user taps "Restore Purchases"
    @objc public class func fetchAllTransactions(progress: PurchaseProductIAPProgress) {
        Task {
            await TransactionManager.trackTransactionUpdate(
                sequence: Transaction.all,
                completion: { _, _ in },
                progress: progress
            )
        }
    }
    /// Called on app open to listen to real-time transaction changes
    private class func fetchTransactionUpdates(progress: PurchaseProductIAPProgress) {
        Task {
            await TransactionManager.trackTransactionUpdate(
                sequence: Transaction.updates,
                completion: { _, _ in },
                progress: progress
            )
        }
    }
    @objc public class func setupTransactionMonitoring(progress: PurchaseProductIAPProgress) {
        
        transactionUpdatesEnabled = true
        guard !sharedInstance.hasStartedUpdates else { return }
        sharedInstance.hasStartedUpdates = true
        
        fetchUnfinishedTransactions(progress: progress)
        fetchTransactionUpdates(progress: progress)
    }
    /// Retries payment validation through credit card with Backend
    @objc public class func retryValidation(completion:@escaping (_ error:Error?,_ amount: Double) -> Void,
                                            progress:@escaping (_ progress: PaymentProgress) -> Void)
    {
        guard let creditCard = sharedInstance.creditCard else {
            return
        }
        creditCard.validateCreditCardPayment { error in
            completion(error, sharedInstance.creditCard?.purchaseAmount ?? 0)
        } progress: { state, error in
            let currentProgress = PaymentProgress(state: state, intentDetails: creditCard.intentPurchaseDetails.build(), error: error)
            progress(currentProgress)
        }
    }
    @objc public static func purchase(productId:String,
                                      completion:@escaping (_ error:Error?,_ amount: Double) -> Void,
                                      progress:@escaping (_ progress: PaymentProgress) -> Void)
    {
        sharedInstance.creditCard?.config.product.id = productId
        sharedInstance.creditCard?.purchase(completion: completion, progress: progress)
    }
    @objc public static func purchase(intent:PaymentIntentResponse,
                                      completion:@escaping (_ error:Error?,_ amount: Double) -> Void,
                                      progress:@escaping (_ progress: PaymentProgress) -> Void)
    {
        sharedInstance.creditCard?.config.intentConfig = intent
        sharedInstance.creditCard?.purchase(completion: completion, progress: progress)
    }
    @objc public static func initializeCardSettings(config: PurchaseConfig)
    {
        sharedInstance.creditCard = CreditCard(config: config)
    }
    @objc public static func handleURLCallback(url:URL) -> Bool
    {
        return sharedInstance.creditCard?.handleURLCallback(url: url) ?? false
    }
    @objc public static func requestRefund(for bundleIdentifier: String,
                                           completion: @escaping (RefundRequestResult,Error?) -> Void)
    {
        Task {
            let (result,error) = await PurchaseManager.requestRefund(for: bundleIdentifier)
            completion(result, error)
        }
    }
}
