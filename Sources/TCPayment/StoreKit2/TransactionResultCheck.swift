//
//  File.swift
//  
//
//  Created by Ali on 06/09/2024.
//

import Foundation
import StoreKit
import TCSharedFramework

struct TransactionResultCheck {
    
    /// 2️⃣ Publicly callable: just unpack the `VerificationResult`
    public static func parseTransaction(_ result: VerificationResult<Transaction>) -> ParsedTransaction
    {
        switch result {
        case .unverified(let tx, let error):
            // clean up StoreKit queue immediately
            TransactionManager.finishTransaction(tx)
            return ParsedTransaction(
                signedType: tx,
                jwsRepresentation: result.jwsRepresentation,
                verificationError: error
            )
            
        case .verified(let tx):
            return ParsedTransaction(
                signedType: tx,
                jwsRepresentation: result.jwsRepresentation,
                verificationError: nil
            )
        }
    }
    
    /// 3️⃣ Your existing verify flow now simply starts by parsing
    static func verify(transaction result: VerificationResult<Transaction>,
                       progress: PurchaseProductIAPProgress,
                       completionHandler: @escaping (_ error: Error?, _ amount: Double) -> Void)
    {
        let parsed = parseTransaction(result)
        // If it was unverified, short‑circuit
        if let error = parsed.verificationError {
            handleUnverified(parsed, progress: progress, completion: completionHandler)
        } else {
            handleVerified(parsed, progress: progress, completion: completionHandler)
        }
    }
    
    // ——————————————————————————————————————————————————
    // MARK: Internal helpers
    
    private static func handleUnverified(_ parsed: ParsedTransaction,
                                         progress: PurchaseProductIAPProgress,
                                         completion: @escaping (_ error: Error?, _ amount: Double) -> Void)
    {
        let purchase = makeDetails(from: parsed)
        let state = TCPaymentTransactionState.fetchState(for: parsed.signedType.productID,
                                                         verified: false,
                                                         action: .appleState)
        progress?(state, parsed.verificationError, purchase)
        completion(parsed.verificationError, 0)
    }
    
    private static func handleVerified(_ parsed: ParsedTransaction,
                                       progress: PurchaseProductIAPProgress,
                                       completion: @escaping (_ error: Error?, _ amount: Double) -> Void)
    {
        let tx = parsed.signedType
        let purchase = makeDetails(from: parsed)
        let checkingState = TCPaymentTransactionState.fetchState(for: tx.productID,
                                                                 action: .serverCheck)
        
        let environment:String
        if #available(iOS 16.0, *) {
            environment = tx.environment == .sandbox ? Environment.sandbox.rawValue : Environment.production.rawValue
        } else {
            environment = TCPayment.sandBox ? Environment.sandbox.rawValue : Environment.production.rawValue
        }
        progress?(checkingState, nil, purchase)
        // build server payload
        let param = PurchaseInfo(
            bundleName: Bundle.main.bundleIdentifier ?? "",
            id: tx.productID,
            environment: environment,
            signedTransaction: parsed.jwsRepresentation,
            transactionId: tx.id,
            signedDate: Int(tx.signedDate.timeIntervalSince1970 * 1_000),
            purchaseDate: Int(tx.purchaseDate.timeIntervalSince1970 * 1_000),
            quantity: tx.purchasedQuantity,
            appAccountToken: tx.appAccountToken?.uuidString,
            appLanguage: TCPayment.language.localeIdentifier,
            deviceIdentifier: TCPayment.deviceIdentifier
        )
        
        let type: TransactionProductType = tx.productID.isSubscription
            ? .subscription
            : .consumable
        
        TransactionVerification.verify(
            param: param,
            transactionId: tx.id,
            type: type
        ) { serverError, amount in
            let action: ActionType = (serverError == nil) ? .serverSuccess : .serverFailed
            let newState = TCPaymentTransactionState.fetchState(
                for: tx.productID,
                action: action
            )
            progress?(newState, serverError, purchase)
            completion(serverError, amount)
            
            TransactionManager.finishTransaction(tx)
        }
    }
    
    private static func makeDetails(from parsed: ParsedTransaction) -> PurchaseDetails {
        PurchaseDetails(
            productId: parsed.signedType.productID,
            appLanguage: TCPayment.language.localeIdentifier,
            transaction: StoreKitTransaction(
                from: parsed.signedType,
                signedTransaction: parsed.jwsRepresentation
            )
        )
    }
}
