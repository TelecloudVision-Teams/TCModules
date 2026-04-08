//
//  File.swift
//  
//
//  Created by Telecloud on 04/06/2024.
//

import Foundation
import Security

@objc(DeviceIdentifierManager)
public class DeviceIdentifierManager: NSObject {
    
    @objc public static let shared = DeviceIdentifierManager()
    var deviceIdentifier = UUID().uuidString
    private let key = "UniqueDeviceIdentifier"
    private let bundle = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier"
    init(deviceIdentifier: String = UUID().uuidString) {
        self.deviceIdentifier = deviceIdentifier
    }
    public func getDeviceIdentifier() -> Result<String, Error> {
        if let existingIdentifier = loadDeviceIdentifier() {
            deviceIdentifier = existingIdentifier
            return .success(existingIdentifier)
        } else {
            switch saveToKeychain(deviceIdentifier) {
            case .success:
                return .success(deviceIdentifier)
            case .failure(let error):
                return .failure(error)
            }
        }
    }
    
    private func loadDeviceIdentifier() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data, let identifier = String(data: data, encoding: .utf8) {
                return identifier
            }
        }
        
        return nil
    }
    
    private func generateDeviceIdentifier() -> String {
        return UUID().uuidString
    }
    
    private func saveToKeychain(_ identifier: String) -> Result<Void, Error> {
        guard let data = identifier.data(using: .utf8) else {
            return .failure(NSError(domain: "\(bundle).Deviceidentifier.Encoding.Error", code: 0))
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            return .success(())
        } else {
            return .failure(NSError(domain: "\(Bundle.main.bundleIdentifier).Deviceidentifier.Keychain.not.available", code: Int(status)))
        }
    }
}
