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
            case .failure(let error):
                if error._code != -1
                {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: { [weak self] in
                        self?.didFetchError?(error)
                    })
                }
                return DeviceIdentifierManager.shared.deviceIdentifier
            }
        }
    }
}
