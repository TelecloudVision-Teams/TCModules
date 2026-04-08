//
//  AnaylticsFirebaseTests.swift
//  AnaylticsFirebaseTests
//
//  Created by Admin on 14/09/2022.
//

import XCTest
@testable import AnalyticsFramework
import FirebaseAnalytics

class AnaylticsFirebaseTests: XCTestCase {

    func testFirebaseProvider() {
        let provider = FirebaseProvider()
//        XCTAssertTrue(provider.cls === Firebase.Analytics.self)
        XCTAssertNil(provider.instance)
//        XCTAssertEqual(provider.selector, #selector(Firebase.Analytics.logEvent(_:parameters:)))
        XCTAssertTrue(provider.responds)
    }
}
