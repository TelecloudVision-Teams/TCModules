//
//  TCAnalyticsProvider.swift
//  TCAnalytics
//
//  Created by Ali on 19/05/2025.
//

import Foundation
@objc public enum TCAnalyticsProvider:Int
{
    case Branch
    case Firebase
    
    var type:AnalyticsProvider
    {
        switch self {
        case .Branch:
            return BranchProvider()
        case .Firebase:
            return FirebaseProvider()
        }
    }
}
