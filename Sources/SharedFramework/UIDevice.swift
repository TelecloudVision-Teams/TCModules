//
//  File.swift
//
//
//  Created by Telecloud on 04/06/2024.
//

import UIKit

extension UIDevice {
    
    @objc public static var deviceIdentifier = DeviceIdentifier()
    
    @objc public class DeviceIdentifier: NSObject
    {
        @objc public var name: String! { return "deviceIdentifier" }
        @objc public var didFetchError:((Error)->Void)?
        @objc public var value: String? {
            let result = DeviceIdentifierManager.shared.getDeviceIdentifier()
            switch result {
            case .success(let success):
                return success
            case .failure(let failure):
                // Added delay 0.2 seconds in case of simultaneous calls to avoid crash
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: { [weak self] in
                    self?.didFetchError?(failure)
                })
                return DeviceIdentifierManager.shared.deviceIdentifier
            }
        }
    }
}
