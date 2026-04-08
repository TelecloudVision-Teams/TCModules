//
//  Environment.swift
//  TCAnalyticsFramework
//
//  Created by Ali on 10/04/2025.
//

import Foundation

@objc public enum AnalyticsEnvironment:Int
{
    case sandbox
    case production
    
    var stringValue: String
    {
        switch self
        {
        case .sandbox:
            return "sandbox"
        case .production:
            return "production"
        }
    }
}
