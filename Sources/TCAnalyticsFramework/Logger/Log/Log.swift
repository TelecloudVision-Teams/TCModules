//
//  Log.swift
//  AnalyticsReporter
//
//  Created by Ali on 05/05/2023.
//

import Foundation

enum LogEvent: String {
    case e = "[‼️]" // error
    case d = "[💬]" // debug
    case s = "[..]" // debug
}

internal class Log {
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    static var enableLogger = false
    
    class func e( _ object: Any?="", error:Error, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if enableLogger == false { return }
            print("Error ----------------------------------- Error")
            print("---- Error: \(error)")
        print("\(Date().toString()) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object ?? "")")
            print("Error ----------------------------------- Error")
    }
    
    /// Logs debug messages on console with prefix [💬]
    
    class func d( _ object: Any?="", filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if enableLogger == false { return }
            print("Debug ----------------------------------- Debug")
            print("\(Date().toString())[\(sourceFileName(filePath: filename))]: \(funcName) -> \(object ?? "")")
            print("Debug ----------------------------------- Debug")
    }
    
    class func s( _ object: Any?="", filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if enableLogger == false { return }
            print("Success ----------------------------------- Success")
            print("\(Date().toString()) \(LogEvent.d.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object ?? "")")
            print("Success ----------------------------------- Success")
    }
    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}
