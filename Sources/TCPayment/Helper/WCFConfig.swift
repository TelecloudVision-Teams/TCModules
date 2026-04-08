//
//  File.swift
//  TCPayment
//
//  Created by Fatima Hashem on 08/01/2025.
//

import Foundation
import TCPaymentValidation

@objcMembers public class WCF: NSObject {
    public var urlWCF:String? {
        didSet {
            TCPayment.paymentValidator = .wcf
        }
    }
}
