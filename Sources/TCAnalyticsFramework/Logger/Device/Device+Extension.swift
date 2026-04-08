//
//  Device+Extension.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import UIKit
import KeychainSwift
import CoreTelephony
import SystemConfiguration

extension UIDevice
{
    var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    @objc public static var deviceLanguage = DeviceLanguage()
    @objc public static var platformType = Platform()
    @objc public static var platformVersion = PlatformVersion()
    @objc public static var timezone = Timezone()
    @objc public static var openUDID = OpenUDID()
    @objc public static var platformTypeID = PlatformTypeID()
    @objc public static var countryName = CountryName()
    @objc public static var carrierName = CarrierName()
    @objc public static var connectionType = ConnectionType()
    @objc public static var isJailbroken = IsJailbroken()
    @objc public static var deviceType = DeviceType()
    @objc public static var timeFormat = TimeFormat()
    
    @objc public class DeviceLanguage: NSObject
    {
        @objc public var name: String! { return "deviceLanguage" }
        @objc public var value: String? { return Locale.current.identifier }
    }
    
    @objc public class Platform: NSObject
    {
        @objc public var name: String! { return "platform" }
        @objc public var value: String? { return "IOS" }
    }
    
    @objc public class PlatformVersion: NSObject
    {
        @objc public var name: String! { return "platformVersion" }
        @objc public var value: String? { return UIDevice.current.systemVersion }
    }
    
    @objc public class Timezone: NSObject
    {
        @objc public var name: String! { return "timeZone" }
        @objc public var value: String? { return TimeZone.current.identifier }
    }
    
    @objc public class OpenUDID: NSObject
    {
        @objc public var name: String! { return "OpenUDID" }
        @objc public var value: String? { return UIDevice.deviceIdentifier.value }
    }
    
    @objc public class PlatformTypeID: NSObject
    {
        @objc public var name: String! { return "PlatformTypeId" }
        @objc public var value: Int { return 1 }
    }
    
    @objc public class CountryName: NSObject
    {
        @objc public var name: String! { return "Country" }
        @objc public var value: String? { return TimeZone.current.identifier }
    }
    @objc public class DeviceType: NSObject
    {
        @objc public var name: String! { return "PlatformDevice" }
        @objc public var value: String? {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0,  count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            return String(cString: machine)
        }
    }
    @objc public class TimeFormat: NSObject
    {
        @objc public var name: String! { return "TimeFormat" }
        @objc public var value: String? {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "a"
            let text = timeFormatter.string(from: Date())
            if text.isEmpty { return "24H" }
            else { return "12H" }
        }
    }
    @objc public class IsJailbroken: NSObject
    {
        @objc public var name: String! { return "IsRooted" }
        @objc public var value: Bool {
            if UIDevice.current.isSimulator { return false }
            if JailBrokenHelper.hasCydiaInstalled() { return true }
            if JailBrokenHelper.isContainsSuspiciousApps() { return true }
            if JailBrokenHelper.isSuspiciousSystemPathsExists() { return true }
            return JailBrokenHelper.canEditSystemFiles()
        }
    }
    @objc public class CarrierName: NSObject
    {
        @objc public var name: String! { return "CarrierName" }
        @objc public var value: String? {
            let networkStatus = CTTelephonyNetworkInfo()
            if let info = networkStatus.serviceSubscriberCellularProviders,
               let carrierName = info.values.filter({$0.carrierName != nil }).first?.carrierName
            {
                return carrierName
            }
            else
            {
                return ""
            }
        }
    }
    
    @objc public class ConnectionType: NSObject
    {
        @objc public var name: String! { return "ConnectionType" }
        @objc public var value: String? {
            guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
                return "NO INTERNET"
            }
            
            var flags = SCNetworkReachabilityFlags()
            SCNetworkReachabilityGetFlags(reachability, &flags)
            
            let isReachable = flags.contains(.reachable)
            let isWWAN = flags.contains(.isWWAN)
            
            if isReachable {
                if isWWAN {
                    let networkInfo = CTTelephonyNetworkInfo()
                    let carrierType = networkInfo.serviceCurrentRadioAccessTechnology
                    
                    guard let carrierTypeName = carrierType?.first?.value else {
                        return "UNKNOWN"
                    }
                    let nameArr = carrierTypeName.components(separatedBy: "CTRadioAccessTechnology")
                    return nameArr.last
                }
                else {
                    return "Wifi"
                }
            } else {
                return "NO INTERNET"
            }
        }
    }
}
private struct JailBrokenHelper {
    static func hasCydiaInstalled() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "cydia://")!)
    }
    
    static func isContainsSuspiciousApps() -> Bool {
        for path in suspiciousAppsPathToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func isSuspiciousSystemPathsExists() -> Bool {
        for path in suspiciousSystemPathsToCheck {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    static func canEditSystemFiles() -> Bool {
        let jailBreakText = "Developer Insider"
        do {
            try jailBreakText.write(toFile: jailBreakText, atomically: true, encoding: .utf8)
            return true
        } catch {
            return false
        }
    }
    
    /**
     Add more paths here to check for jail break
     */
    static var suspiciousAppsPathToCheck: [String] {
        return ["/Applications/Cydia.app",
                "/Applications/blackra1n.app",
                "/Applications/FakeCarrier.app",
                "/Applications/Icy.app",
                "/Applications/IntelliScreen.app",
                "/Applications/MxTube.app",
                "/Applications/RockApp.app",
                "/Applications/SBSettings.app",
                "/Applications/WinterBoard.app"
        ]
    }
    
    static var suspiciousSystemPathsToCheck: [String] {
        return ["/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                "/private/var/lib/apt",
                "/private/var/lib/apt/",
                "/private/var/lib/cydia",
                "/private/var/mobile/Library/SBSettings/Themes",
                "/private/var/stash",
                "/private/var/tmp/cydia.log",
                "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                "/usr/bin/sshd",
                "/usr/libexec/sftp-server",
                "/usr/sbin/sshd",
                "/etc/apt",
                "/bin/bash",
                "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
    }
}
