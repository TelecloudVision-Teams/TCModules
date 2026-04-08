//
//  DeviceInfo.swift
//  AnalyticsReporter
//
//  Created by Ali on 03/05/2023.
//

import TCLocationFramework
import UIKit

struct DeviceInfo {
    let guid:String
    var openUDID:String = UIDevice.openUDID.value ?? ""
    var platformTypeID:Int = UIDevice.platformTypeID.value
    var latitude:Double = TCLocationManager.shared.latitude
    var longitude:Double = TCLocationManager.shared.longitude
    var countryName:String = TCLocationManager.shared.isoCode
    var carrierName:String = UIDevice.carrierName.value ?? ""
    var connectionType:String = UIDevice.connectionType.value ?? ""
    var isJailbroken:Bool = UIDevice.isJailbroken.value
    var platformVersion:String = UIDevice.platformVersion.value ?? ""
    var deviceType:String = UIDevice.deviceType.value ?? ""
    var timeFormat:String = UIDevice.timeFormat.value ?? ""
    var timeZone = TimeZone.current.identifier
    var language = Locale.preferredLanguages.first ?? ""
    
    mutating func refresh()
    {
        openUDID = UIDevice.openUDID.value ?? ""
        platformTypeID = UIDevice.platformTypeID.value
        latitude = TCLocationManager.shared.latitude
        longitude = TCLocationManager.shared.longitude
        countryName = TCLocationManager.shared.countryName
        carrierName = UIDevice.carrierName.value ?? ""
        connectionType = UIDevice.connectionType.value ?? ""
        isJailbroken = UIDevice.isJailbroken.value
        platformVersion = UIDevice.platformVersion.value ?? ""
        deviceType = UIDevice.deviceType.value ?? ""
        timeFormat = UIDevice.timeFormat.value ?? ""
        timeZone = TimeZone.current.identifier
        language = Locale.preferredLanguages.first ?? ""
    }
}
