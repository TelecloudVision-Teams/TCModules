//
//  TCLanguage.swift
//  TCPayment
//
//  Created by Ali on 06/05/2025.
//

@objc public enum TCPaymentLanguage:Int {
    case english
    case turkish
    case arabic
    case spanish
    case portuguese
    
    var localeIdentifier:String {
        switch self {
        case .english:
            return "en"
        case .turkish:
            return "tr"
        case .arabic:
            return "ar"
        case .spanish:
            return "es"
        case .portuguese:
            return "pt"
        }
    }
    init?(localeIdentifier: String) {
        switch localeIdentifier.lowercased() {
        case "en": self = .english
        case "tr": self = .turkish
        case "ar": self = .arabic
        case "es": self = .spanish
        case "pt": self = .portuguese
        default: return nil
        }
    }
}

