
import Foundation

@objc public class IntentFetchMessage: NSObject{
    public static var message:String = ""
}

@objc public enum TCPaymentTransactionState : Int{
    
    case LogIAPPendingPurchase
    case LogIAPClickPurchase
    case LogIAPCancelPurchase
    case LogIAPFailedPurchase
    case LogIAPSuccessPurchase
    case LogIAPCheckPurchaseBeforeSending
    case LogIAPSuccessPurchaseAfterSendingData
    case LogIAPFailedPurchaseAfterSendingData
    case LogIAPDeferredPurchase
    
    case LogSubscriptionClickPurchase
    case LogSubscriptionPendingPurchase
    case LogSubscriptionFailedPurchase
    case LogSubscriptionCancelPurchase
    case LogSubscriptionSuccessPurchase
    case LogSubscriptionCheckPurchaseBeforeSending
    case LogSubscriptionSuccessPurchaseAfterSendingData
    case LogSubscriptionFailedPurchaseAfterSendingData
    case LogSubscriptionDeferredPurchase
    
    case LogSubscriptionRestoreClickPurchase
    case LogSubscriptionRestoreFailedPurchase
    case LogSubscriptionRestoreSuccessPurchase
    case LogSubscriptionSuccessRestoreAfterSendingData
    case LogSubscriptionFailedRestoreAfterSendingData
    case LogIAPCheckRestoreBeforeSending
    case LogSubscriptionCheckRestoreBeforeSending
    case LogIAPSuccessRestoreAfterSendingData
    case LogIAPFailedRestoreAfterSendingData
    
    case LogStripeIntentPurchaseStarted
    case LogStripeIntentFetchSuccess
    case LogStripeIntentFetchFailure
    case LogStripeIntentFlowCompleted
    case LogStripeIntentFlowCanceled
    case LogStripeIntentFlowError
    case LogStripeIntentCheckingStarted
    case LogStripeIntentCheckingSuccess
    case LogStripeIntentCheckingFailure
    
    case LogIAPRetrieveProductsInfoSuccess
    case LogIAPRetrieveProductsInfoFailed

    public func value() -> String {
      switch self {
      case .LogIAPPendingPurchase: return "IAP Purchase Pending Queue 2"
      case .LogIAPClickPurchase: return "IAP Purchase Clicked 1"
      case .LogIAPCancelPurchase: return "IAP Purchase Cancelled 2"
      case .LogIAPFailedPurchase: return "IAP Purchase Failed From Apple 2"
      case .LogIAPSuccessPurchase: return "IAP Purchase Success From Apple 2"
      case .LogIAPCheckPurchaseBeforeSending: return "IAP Purchase Checking Started 3"
      case .LogIAPSuccessPurchaseAfterSendingData: return "IAP Purchase Checking Ended With Success 4"
      case .LogIAPFailedPurchaseAfterSendingData: return "IAP Purchase Checking Ended With Failure 4"
      case .LogIAPDeferredPurchase: return "IAP Purchase Deferred From Apple 2"

      case .LogSubscriptionClickPurchase: return "Subscription Purchase Clicked 1"
      case .LogSubscriptionPendingPurchase: return "Subscription Purchase Pending Queue 2"
      case .LogSubscriptionFailedPurchase: return "Subscription Purchase Failed 2"
      case .LogSubscriptionCancelPurchase: return "Subscription Purchase Cancelled 2"
      case .LogSubscriptionSuccessPurchase: return "Subscription Purchase Success 2"
      case .LogSubscriptionCheckPurchaseBeforeSending: return "Subscription Purchase Checking Started 3"
      case .LogSubscriptionDeferredPurchase: return "Subscription Purchase Deferred"
      case .LogSubscriptionSuccessPurchaseAfterSendingData: return "Subscription Purchase Checking Ended With Success 4"
      case .LogSubscriptionFailedPurchaseAfterSendingData: return "Subscription Purchase Checking Ended With Failure 4"
          
      case .LogStripeIntentPurchaseStarted: return "Stripe Intent Purchase Started 1"
      case .LogStripeIntentFetchSuccess: return "Stripe Intent Fetch Success 2 - \(IntentFetchMessage.message)"
      case .LogStripeIntentFetchFailure: return "Stripe Intent Fetch Failure 2 - \(IntentFetchMessage.message)"
      case .LogStripeIntentFlowCompleted: return "Stripe Intent Flow Completed 3"
      case .LogStripeIntentFlowCanceled: return "Stripe Intent Flow Canceled 3"
      case .LogStripeIntentFlowError: return "Stripe Intent Flow Error 3"
      case .LogStripeIntentCheckingStarted: return "Stripe Intent Checking Started 4"
      case .LogStripeIntentCheckingSuccess: return "Stripe Intent Checking Success 5"
      case .LogStripeIntentCheckingFailure: return "Stripe Intent Checking Failure 5"
      

      case .LogSubscriptionRestoreClickPurchase: return "Subscription Restore Clicked 1"
      case .LogSubscriptionRestoreFailedPurchase: return "Subscription Restore Failed 2"
      case .LogSubscriptionRestoreSuccessPurchase: return "Subscription Restore Success 2"
      case .LogSubscriptionSuccessRestoreAfterSendingData: return "Subscription Restore Checking Ended With Success 4"
      case .LogSubscriptionFailedRestoreAfterSendingData: return "Subscription Restore Checking Ended With Failure 4"
      case .LogIAPSuccessRestoreAfterSendingData: return "IAP Restore Checking Ended With Success 4"
      case .LogIAPFailedRestoreAfterSendingData: return "IAP Restore Checking Ended With Failure 4"
      case .LogIAPCheckRestoreBeforeSending: return "IAP Restore Checking Started 3"
      case .LogSubscriptionCheckRestoreBeforeSending: return "Subscription Restore Checking Started 3"
          
          
      case .LogIAPRetrieveProductsInfoSuccess: return "IAP Retrieve Products Info successfully"
      case .LogIAPRetrieveProductsInfoFailed: return "IAP Retrieve Products Info failed"
      }
    }
}

