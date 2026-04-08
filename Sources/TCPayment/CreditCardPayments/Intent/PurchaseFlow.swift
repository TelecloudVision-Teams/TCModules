//
//  PurchaseFlow.swift
//  TCPayment
//
//  Created by Ali on 22/10/2025.
//

protocol PurchaseFlow {
    func start(ctx: PurchaseContext,
               completion: @escaping (_ error: Error?, _ amount: Double) -> Void,
               progress: @escaping (_ progress: PaymentProgress) -> Void)
}
