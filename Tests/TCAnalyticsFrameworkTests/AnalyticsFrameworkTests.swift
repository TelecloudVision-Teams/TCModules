//
//  AnalyticsFrameworkTests.swift
//  AnalyticsFrameworkTests
//
//  Created by Admin on 14/09/2022.
//

import XCTest
@testable import AnalyticsFramework

class AnalyticsFrameworkTests: XCTestCase {
    var analytics: Analytics!
    var firebaseProvider: MockProvider!
    var fabricProvider: MockProvider!
    
    override func setUp() {
        super.setUp()
        
        self.firebaseProvider = MockProvider()
        self.fabricProvider = MockProvider()
    }
    
    func testAnalytics_singleProvider() {
        Analytics.shared.register(provider: self.firebaseProvider, Key: "")
        Analytics.shared.log(for: "login", parameters: ["username": "devxoul"])
        XCTAssertEqual(self.firebaseProvider.events.count, 1)
        XCTAssertEqual(self.firebaseProvider.events[0].name, "login")
        XCTAssertEqual(self.firebaseProvider.events[0].parameters!.count, 1)
        XCTAssertEqual(self.firebaseProvider.events[0].parameters!["username"] as! String, "devxoul")
    }
    
    func testAnalytics_singleProvider_nilName() {
        Analytics.shared.register(provider: self.fabricProvider, Key: "")
        Analytics.shared.log(for: "purchase", parameters:["product_id": 123, "price": 99.9])
        XCTAssertEqual(self.fabricProvider.events.count, 1)
    }

}
