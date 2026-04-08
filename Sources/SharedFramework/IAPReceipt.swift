//
//  File.swift
//  
//
//  Created by Telecloud on 04/06/2024.
//

import Foundation

public struct IAPReceipt {
    public static var receipt:Data?
    {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptUrl) else { return nil }
        return receiptData
    }
    public static var receiptString:String
    {
        guard let receipt = receipt else { return "Invalid Receipt" }
        return receipt.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }
    public static var escapedReceipt:String
    {
        return receiptString.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "Invalid Receipt"
    }
}
