//
//  File.swift
//  
//
//  Created by Telecloud on 04/06/2024.
//

import Foundation
import Security
import UIKit

@objc(DeviceIdentifierManager)
public class DeviceIdentifierManager: NSObject {

    // MARK: - Singleton

    @objc public static let shared = DeviceIdentifierManager()

    // Always non-nil. Starts with a random UUID, later overwritten by Keychain if available.
    @objc public private(set) var deviceIdentifier: String

    // MARK: - Private keys

    private let accountKey = "UniqueDeviceIdentifier"
    private let bundleId: String
    private let service: String

    // MARK: - Init

    override private init() {
        self.bundleId = Bundle.main.bundleIdentifier ?? "unknown.bundle.identifier"
        self.service = bundleId + ".deviceidentifier"
        self.deviceIdentifier = UUID().uuidString   // never nil

        super.init()

        // If protected data is already available, sync with Keychain immediately.
        if UIApplication.shared.isProtectedDataAvailable {
            _ = syncWithKeychain()
        }

        // When device unlocks after boot, this fires.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(protectedDataDidBecomeAvailable(_:)),
            name: UIApplication.protectedDataDidBecomeAvailableNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Public API (Swift)

    /// Main API. Returns Result so callers can know if Keychain failed.
    /// Regardless of failure/success, `deviceIdentifier` is always non-nil.
    public func getDeviceIdentifier() -> Result<String, Error> {
        // If protected data isn't available, do NOT touch Keychain.
        guard UIApplication.shared.isProtectedDataAvailable else {
            let error = NSError(
                domain: "\(bundleId).Deviceidentifier.ProtectedData",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Protected data is not available; using in-memory deviceIdentifier only."]
            )
            // deviceIdentifier already has a valid UUID at all times.
            return .failure(error)
        }

        if let stored = loadFromKeychain() {
            if stored != deviceIdentifier {
                deviceIdentifier = stored
            }
            return .success(stored)
        }

        // Nothing in Keychain → store current non-nil deviceIdentifier.
        let idToStore = deviceIdentifier

        switch saveToKeychain(idToStore) {
        case .success:
            return .success(idToStore)
        case .failure(let error):
            // Even if this fails, we still have `deviceIdentifier` in memory.
            return .failure(error)
        }
    }

    /// Convenience: non-Result version if you don't care about errors.
    /// Always returns a non-empty String.
    public func resolvedIdentifier() -> String {
        switch getDeviceIdentifier() {
        case .success(let id):
            return id
        case .failure:
            return deviceIdentifier
        }
    }

    // MARK: - Public API (Objective-C friendly)

    /// Objective-C wrapper. Always returns a non-nil NSString.
    /// On error, fills `error` and returns the current in-memory deviceIdentifier.
    @objc
    public func deviceIdentifierWithError(_ error: NSErrorPointer) -> NSString {
        switch getDeviceIdentifier() {
        case .success(let id):
            return id as NSString
        case .failure(let e):
            error?.pointee = e as NSError
            return deviceIdentifier as NSString
        }
    }

    // MARK: - Protected data handling

    @objc
    private func protectedDataDidBecomeAvailable(_ notification: Notification) {
        _ = syncWithKeychain()
    }

    /// Syncs in-memory `deviceIdentifier` with Keychain once protected data is available.
    /// - If item exists in Keychain → load it and overwrite `deviceIdentifier`.
    /// - If not → write current `deviceIdentifier` to Keychain.
    @discardableResult
    private func syncWithKeychain() -> Bool {
        guard UIApplication.shared.isProtectedDataAvailable else { return false }

        if let stored = loadFromKeychain() {
            deviceIdentifier = stored
            return true
        } else {
            switch saveToKeychain(deviceIdentifier) {
            case .success:
                return true
            case .failure:
                return false
            }
        }
    }

    // MARK: - Keychain

    private func loadFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let id = String(data: data, encoding: .utf8) else {
            return nil
        }

        return id
    }

    private func saveToKeychain(_ identifier: String) -> Result<Void, Error> {
        guard let data = identifier.data(using: .utf8) else {
            let e = NSError(
                domain: "\(bundleId).Deviceidentifier.Encoding",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode identifier as UTF-8."]
            )
            return .failure(e)
        }

        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: accountKey
        ]

        // Remove existing item for this account/service.
        SecItemDelete(baseQuery as CFDictionary)

        var addQuery = baseQuery
        addQuery[kSecValueData as String] = data

        // Safer accessibility for background / after reboot.
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(addQuery as CFDictionary, nil)

        guard status == errSecSuccess else {
            let description: String
            switch status {
            case errSecInteractionNotAllowed:
                description = "Keychain interaction not allowed (device locked / protected data not available)."
            case errSecNotAvailable:
                description = "Keychain not available."
            default:
                description = "Keychain save failed with status \(status)."
            }

            let error = NSError(
                domain: "\(bundleId).Deviceidentifier.Keychain",
                code: Int(status),
                userInfo: [NSLocalizedDescriptionKey: description]
            )
            return .failure(error)
        }

        return .success(())
    }
}
