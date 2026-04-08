//
//  Language.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import Foundation

@objc public enum TCLanguage:Int {
    case arabic = 1
    case english = 2
    case french = 3
    case turkish = 4
    case portuguese = 7
    case spanish = 8
    
    public var string:String {
        
        switch self {
        case .arabic: return "ar"
        case .english: return "en"
        case .french: return "fr"
        case .turkish: return "tr"
        case .portuguese: return "pt"
        case .spanish: return "es"
        }
    }
}
