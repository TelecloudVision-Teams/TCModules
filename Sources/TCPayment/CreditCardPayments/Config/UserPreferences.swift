//
//  UserPreferences.swift
//  TCPayment
//
//  Created by Ali on 08/04/2025.
//

import Foundation

@objcMembers
public class UserPreferences: NSObject {
    public let professionalId: String?
    public var saveCard: Bool?
    public var attemptAutoTopup: Bool?

    public init(professionalId: String? = nil, saveCard: Bool? = nil, attemptAutoTopup: Bool? = nil) {
        self.professionalId = professionalId
        self.saveCard = saveCard
        self.attemptAutoTopup = attemptAutoTopup
    }
    @objc public override init() {
        self.professionalId = nil
        self.saveCard = nil
        self.attemptAutoTopup = nil
    }
    @objc public init(professionalId: String) {
        self.professionalId = professionalId
        self.saveCard = nil
        self.attemptAutoTopup = nil
    }
    public func saveCard(_ saveCard: Bool) {
        self.saveCard = saveCard
    }
    public func attemptAutoTopup(_ attemptAutoTopup: Bool) {
        self.attemptAutoTopup = attemptAutoTopup
    }
}
