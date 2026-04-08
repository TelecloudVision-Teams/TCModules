//
//  RechargeType.swift
//  TCPayment
//
//  Created by Admin on 13/07/2022.
//

import Foundation

@objc public enum RechargeType:Int {
    case iAP
    case audio
    case video
    case appointment
    
    public var description:String
    {
        switch self {
        case .iAP:
            return "InApp"
        case .audio:
            return "VoiceCall"
        case .video:
            return "VideoCall"
        case .appointment:
            return "Appointment"
        }
    }
}
