//
//  TCAnalyticsConfiguration.swift
//  TCAnalytics
//
//  Created by Ali on 14/05/2025.
//

import Foundation

@objcMembers public class TCAnalyticsConfiguration: NSObject {
    /// Called whenever *any* config value changes.
    public var onChange: ((TCAnalyticsConfiguration) -> Void)?

    public var userId: String? {
        didSet { onChange?(self) }
    }
    public var language: TCLanguage? {
        didSet { onChange?(self) }
    }
    public var maxRetries: Int = 1 {
        didSet { onChange?(self) }
    }
    public var retryInterval: TimeInterval = 1 {
        didSet { onChange?(self) }
    }
    public var networkTimeout: TimeInterval = 6 {
        didSet { onChange?(self) }
    }
    public var uuid: String = "" {
        didSet { onChange?(self) }
    }
    public var environment: AnalyticsEnvironment = .production {
        didSet { onChange?(self) }
    }

    public override init() {
        super.init()
        // defaults are already set on declaration
    }
}
