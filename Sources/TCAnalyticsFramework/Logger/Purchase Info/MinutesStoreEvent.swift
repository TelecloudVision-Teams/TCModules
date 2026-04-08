//
//  MinutesStoreEvent.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import Foundation
@objc public enum MinutesStoreEvent:Int
{
    case clicked
    case success
    case failed
    
    func description(type:PurchaseItemType)->String
    {
        let param = type == .voice ? "Voice" : "Video"
        switch self {
        case .clicked:
            return "\(param) Purchase Checking Started 1"
        case .success:
            return "\(param) Purchase Success"
        case .failed:
            return "\(param) Purchase Failed"
        }
    }
}
