//
//  File.swift
//
//
//  Created by Ali on 05/09/2024.
//

import Foundation
import StoreKit
import TCSharedFramework

class TransactionManager
{
    static func trackTransactionUpdate(sequence: Transaction.Transactions,
                                       completion: @escaping (_ error: Error?, _ amount: Double) -> (),
                                       progress: PurchaseProductIAPProgress) async {
        Task.detached {
            for await result in sequence {
                guard case .verified(let transaction) = result else { continue }
                guard transaction.revocationDate == nil else {
                    print("Transaction skipped due to revocation: \(transaction.id)")
                    await transaction.finish()
                    continue
                }
                if let expiry = transaction.expirationDate, expiry <= Date() {
                    print("Transaction skipped due to expiration: \(transaction.id)")
                    await transaction.finish()
                    continue
                }
                if !TCPayment.transactionUpdatesEnabled {
                    print("Transaction skipped due to missing userID: \(transaction.id)")
                    continue
                }
                let wasHandled = TransactionContextManager.shared.handle(transaction: transaction, progress: progress, fallback: { transaction in
                        TransactionResultCheck.verify(transaction: result,progress: progress,completionHandler: completion)
                    }
                )

                if wasHandled {
                    continue
                }
            }
        }
    }
    static func finishTransaction(_ transaction: Transaction, error:Error? = nil) {
        Task
        {
            await transaction.finish()
        }
    }
}

