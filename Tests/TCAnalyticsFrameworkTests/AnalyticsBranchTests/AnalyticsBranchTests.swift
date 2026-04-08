//
//  AnalyticsBranchTests.swift
//  AnalyticsBranchTests
//
//  Created by Admin on 14/09/2022.
//

import XCTest
@testable import AnalyticsFramework
import Branch

final class AnalyticsBranchTests: XCTestCase {

    func testBranchProvider() {
        let provider = BranchProvider()
        XCTAssertTrue(provider.cls === Branch.self)
        XCTAssertNotNil(provider.instance)
        XCTAssertEqual(provider.selector, #selector(.userCompletedAction(_:withState:)))
        XCTAssertTrue(provider.responds)
    }
}


