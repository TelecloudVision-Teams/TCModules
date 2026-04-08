//
//  String+Extension.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import Foundation
extension String
{
    public func numberOfOccurrencesOf(string: String) -> Int {
        return self.components(separatedBy:string).count - 1
    }
    
    public static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    public func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating public func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
