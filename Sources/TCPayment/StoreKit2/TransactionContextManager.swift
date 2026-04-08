//
//  TransactionContextManager.swift
//  TCPayment
//
//  Created by Ali on 08/05/2025.
//
/// `TransactionContextManager` ensures that in-app purchase transactions are handled
/// in the correct UI context, avoiding duplicate verifications and ensuring the UI
/// (e.g., loader, success message) responds only once — even if the transaction is
/// completed via `Transaction.updates` rather than `purchase()`.
///
/// This is particularly important with StoreKit 2 where `Transaction.updates` can emit
/// verified transactions *before* the `purchase()` flow completes (e.g., when the user
/// hasn't clicked "OK" on the App Store sheet yet).
///
/// ## Usage:
///
/// - Call `begin(productID:completion:progress:)` **before starting a purchase**, to register
///   the transaction context.
/// - Call `completeIfMatching(transaction:)` **from any point** (purchase flow or updates listener).
///   This ensures only the registered context handles the callback.
/// - The manager auto-clears itself after completion.
///
/// ## Example:
/// ```swift
/// TransactionContextManager.shared.begin(
///     productID: product.id,
///     completion: { error, amount in
///         // Update UI and finish loader here
///     },
///     progress: progressLogger
/// )
///
/// // Later, when transaction arrives:
/// if !TransactionContextManager.shared.completeIfMatching(transaction: tx) {
///     // fallback logic
/// }
/// ```
///
/// ## Benefits:
/// - Prevents duplicate verification and UI updates
/// - Allows `Transaction.updates` and `purchase()` to co-exist cleanly
/// - Avoids stale loader states or missing success feedback
///
import StoreKit

final class TransactionContextManager {
    static let shared = TransactionContextManager()

    private var expectedProductID: String?
    private var completion: PurchaseResultAlias!
    private var progress: PurchaseProductIAPProgress!
    private var handledTransactionIDs = Set<Transaction.ID>()
    private let lock = NSLock()

    /// Begin tracking a purchase context for a specific product
    func begin(productID: String,
               completion: PurchaseResultAlias,
               progress: PurchaseProductIAPProgress?) {
        expectedProductID = productID
        self.completion = completion
        self.progress = progress
    }

    /// Check if a transaction was already handled (by ID)
    func hasHandled(transaction: Transaction) -> Bool {
        print("Handled Ids: \(handledTransactionIDs)")
        lock.lock()
        defer { lock.unlock() }
        return handledTransactionIDs.contains(transaction.id)
    }

    /// Mark a transaction as handled (by ID)
    func markHandled(transaction: Transaction) {
        lock.lock()
        handledTransactionIDs.insert(transaction.id)
        lock.unlock()
    }

    func handle(transaction: Transaction,
                progress: PurchaseProductIAPProgress?,
                fallback: @escaping (_ transaction: Transaction) -> Void) -> Bool {
        
        // Step 1: Try context match and verify
        if completeIfMatching(transaction: transaction) {
            return true
        }

        // Step 2: Block duplicates
        if hasHandled(transaction: transaction) {
            print("TransactionContextManager: Already handled transaction \(transaction.id), skipping.")
            return true
        }

        // Step 3: Mark as handled and allow fallback
        markHandled(transaction: transaction)
        print("TransactionContextManager: Handling transaction via fallback \(transaction.id)")
        fallback(transaction)
        return false
    }
    /// Complete the purchase flow if the incoming transaction matches
    ///
    /// - Returns: true if handled by context, false otherwise
    func completeIfMatching(transaction: Transaction) -> Bool {
        guard let expected = expectedProductID,
              transaction.productID == expected,
              let completion = completion else {
            return false
        }

        if hasHandled(transaction: transaction) {
            return true // Already verified through some other path
        }

        // Clear state before triggering completion
        expectedProductID = nil
        self.completion = nil
        let progress = self.progress
        self.progress = nil

        // ✅ Mark as handled to prevent duplicate fallback
        markHandled(transaction: transaction)

        TransactionResultCheck.verify(transaction: .verified(transaction), progress: progress!) { error, amount in
            completion?(error, amount)
        }

        return true
    }

    /// Cancel any ongoing transaction context
    func clear() {
        expectedProductID = nil
        completion = nil
        progress = nil
    }

    /// Check if the given product ID is being awaited
    func isAwaiting(productID: String) -> Bool {
        return expectedProductID == productID
    }
}
