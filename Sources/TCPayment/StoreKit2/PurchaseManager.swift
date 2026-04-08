import Foundation
import StoreKit
import TCSharedFramework
import UIKit

@MainActor
class PurchaseManager {
    private static func topViewController() -> UIViewController? {
        guard let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else { return nil }
        
        var topController = keyWindow.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    private func topScene() -> UIScene? {
        return UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive })
    }
    
    private func purchase(product: Product?,
                          options: Set<Product.PurchaseOption> = []) async throws -> Product.PurchaseResult? {
        guard let product = product else { return nil }
        
        if #available(iOS 18.2, tvOS 18.2, visionOS 2.2, *), let viewController = PurchaseManager.topViewController() {
            return try await product.purchase(confirmIn: viewController, options: options)
        } else if #available(iOS 17.0, tvOS 17.0, visionOS 1.0, *), let scene = topScene() {
            return try await product.purchase(confirmIn: scene, options: options)
        } else {
            return try await product.purchase(options: options)
        }
    }
    
    static func purchase(product: Product?,
                         quantity: Int = 1,
                         completion: PurchaseResultAlias,
                         progress: PurchaseProductIAPProgress) async {
        
        guard let product = product else {
            completion?(nil, 0)
            return
        }
        
        let purchaseDetails = PurchaseDetails(productId: product.id,
                                              appLanguage: TCPayment.language.localeIdentifier)
        
        do {
            let purchaseManager = PurchaseManager()
            var options: Set<Product.PurchaseOption> = []
            options.insert(.quantity(quantity))
            if let uuid = UUID(uuidString: TCPayment.userID)
            {
                options.insert(.appAccountToken(uuid))
            }
            
            TransactionContextManager.shared.begin(
                productID: product.id,
                completion: completion,
                progress: progress
            )
            let result = try await purchaseManager.purchase(
                product: product,
                options: options
            )
            
            switch result {
            case .success(let verification):
                let parsed = TransactionResultCheck.parseTransaction(verification)
                let transaction = parsed.signedType
                let purchase = PurchaseDetails(productId: transaction.productID,
                                               appLanguage: TCPayment.language.localeIdentifier,
                                               transaction: StoreKitTransaction(from: transaction,
                                                                                signedTransaction: parsed.jwsRepresentation))
                
                let state = TCPaymentTransactionState.fetchState(for: product.id, verified: true, action: .appleState)
                progress?(state, nil, purchase)
                
                TransactionContextManager.shared.handle(transaction: transaction, progress: progress, fallback: { transaction in
                        TransactionResultCheck.verify(transaction: verification,progress: progress) { error, amount in
                            completion?(error, amount)
                        }
                    }
                )
                
            case .userCancelled:
                let error = PurchaseError(code: .cancel, productIdentifier: product.id)
                progress?(product.id.isSubscription ? .LogSubscriptionCancelPurchase : .LogIAPCancelPurchase, error, purchaseDetails)
                completion?(error, 0)
                
            case .pending:
                let error = PurchaseError(code: .pending, productIdentifier: product.id)
                progress?(product.id.isSubscription ? .LogSubscriptionDeferredPurchase : .LogIAPDeferredPurchase, error, purchaseDetails)
                completion?(error, 0)
                
            case .none:
                let error = PurchaseError(code: .general, productIdentifier: product.id)
                progress?(product.id.isSubscription ? .LogSubscriptionFailedPurchase : .LogIAPFailedPurchase, error, purchaseDetails)
                completion?(error, 0)
                
            @unknown default:
                let error = PurchaseError(code: .general, productIdentifier: product.id)
                progress?(product.id.isSubscription ? .LogSubscriptionFailedPurchase : .LogIAPFailedPurchase, error, purchaseDetails)
                completion?(error, 0)
            }
            
        } catch {
            progress?(product.id.isSubscription ? .LogSubscriptionFailedPurchase : .LogIAPFailedPurchase, error, purchaseDetails)
            completion?(error, 0)
        }
    }
    static func restorePurchases(completion: @escaping (_ error: Error?) -> (),
                                 progress: PurchaseProductIAPProgress) async {
        var isEmpty = true
        
        for await verification in Transaction.currentEntitlements {
            print("Entitlement: \(verification)")
            isEmpty = false
            TransactionResultCheck.verify(transaction: verification, progress: progress) { error, _ in
                completion(error)
            }
        }
        
        if isEmpty {
            let error = NSError(domain: "No transactions exist", code: 0)
            progress?(.LogSubscriptionRestoreFailedPurchase, error, nil)
            completion(error)
        }
    }
    static func requestRefund(for bundleIdentifier: String) async -> (RefundRequestResult, Error?) {
        guard let windowScene = PurchaseManager.topViewController()?.view.window?.windowScene else {
            return (.windowSceneUnavailable, nil)
        }
        
        guard case .verified(let transaction) = await Transaction.latest(for: bundleIdentifier) else {
            return (.transactionUnavailable, nil)
        }
        
        do {
            let status = try await transaction.beginRefundRequest(in: windowScene)
            switch status {
            case .userCancelled:
                return (.cancelled, nil)
            case .success:
                return (.success, nil)
            @unknown default:
                return (.unknownError, NSError(domain: "RefundError", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Unhandled refund status: \(status)"
                ]))
            }
        } catch StoreKit.Transaction.RefundRequestError.duplicateRequest {
            return (.duplicateRequest, StoreKit.Transaction.RefundRequestError.duplicateRequest)
        } catch StoreKit.Transaction.RefundRequestError.failed {
            return (.failed, StoreKit.Transaction.RefundRequestError.failed)
        } catch {
            return (.unknownError, error)
        }
    }
}
