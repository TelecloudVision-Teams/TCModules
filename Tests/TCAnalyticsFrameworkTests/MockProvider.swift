//
//  MockProvider.swift
//  AnalyticsFrameworkTests
//
//  Created by Admin on 14/09/2022.
//

import AnalyticsFramework

class MockProvider: ProviderType {
    func initialize(Key: String?) {
    }
    
    var events: [(name: String, parameters: [String: Any]?)] = []
    
    func log(_ eventName: String, parameters: [String: Any]?) {
        self.events.append((name: eventName, parameters: parameters))
    }
}

