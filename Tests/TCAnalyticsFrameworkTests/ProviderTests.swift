//
//  ProviderTests.swift
//  AnalyticsFrameworkTests
//
//  Created by Admin on 14/09/2022.
//

import XCTest
import AnalyticsFramework

final class ClassAnalytics: NSObject {
    static var loggedEvents: [(name: String, parameters: [String: Any]?)] = []
    
    @objc class func logEvent(_ eventName: String, parameters: [String: Any]?) {
        self.loggedEvents.append((name: eventName, parameters: parameters))
    }
}

final class ClassProvider: Provider {
    func initialize(Key: String?) {}
    
    let className: String = "AnalyticsFrameworkTests.ClassAnalytics"
    let selectorName: String = "logEvent:parameters:"
    var instanceSelectorName: String? = nil
    public func log(_ eventName: String, parameters: [String : Any]?) {
        guard self.responds else { return }
        if let instance = self.instance {
            _ = instance.perform(self.selector, with: eventName, with: parameters)
        } else {
            _ = self.cls?.perform(self.selector, with: eventName, with: parameters)
        }
    }
}

@objc final class InstanceAnalytics: NSObject {
    @objc static let shared = InstanceAnalytics()
    var loggedEvents: [(name: String, parameters: [String: Any]?)] = []
    
    @objc func logEvent(_ eventName: String, parameters: [String: Any]?) {
        self.loggedEvents.append((name: eventName, parameters: parameters))
    }
}

final class InstanceProvider: Provider {
    func initialize(Key: String?) {}
    
    let className: String = "AnalyticsFrameworkTests.InstanceAnalytics"
    let instanceSelectorName: String? = "shared"
    let selectorName: String = "logEvent:parameters:"
    public func log(_ eventName: String, parameters: [String : Any]?) {
        guard self.responds else { return }
        if let instance = self.instance {
            _ = instance.perform(self.selector, with: eventName, with: parameters)
        } else {
            _ = self.cls?.perform(self.selector, with: eventName, with: parameters)
        }
    }
}

final class InvalidProvider: Provider {
    func initialize(Key: String?) {}
    
    let className: String = "UnknownClass"
    let instanceSelectorName: String? = "shared"
    let selectorName: String = "logEvent:parameters:"
    public func log(_ eventName: String, parameters: [String : Any]?) {
        guard self.responds else { return }
        if let instance = self.instance {
            _ = instance.perform(self.selector, with: eventName, with: parameters)
        } else {
            _ = self.cls?.perform(self.selector, with: eventName, with: parameters)
        }
    }
}

final class ProviderTests: XCTestCase {
    override func setUp() {
        super.setUp()
        ClassAnalytics.loggedEvents.removeAll()
        InstanceAnalytics.shared.loggedEvents.removeAll()
    }
    
    func testClassProvider() {
        let provider = ClassProvider()
        provider.log("purchase", parameters: ["product_id": 123, "price": 9.99])
        print(Bundle.main.infoDictionary!["CFBundleName"] as! String)
        XCTAssertTrue(provider.cls === ClassAnalytics.self)
        XCTAssertEqual(provider.selector, #selector(ClassAnalytics.logEvent(_:parameters:)))
        XCTAssertTrue(provider.responds)
        XCTAssertEqual(ClassAnalytics.loggedEvents.count, 1)
        if ClassAnalytics.loggedEvents.count != 0{
        XCTAssertEqual(ClassAnalytics.loggedEvents[0].name, "purchase")
        XCTAssertEqual(ClassAnalytics.loggedEvents[0].parameters!["product_id"] as! Int, 123)
        XCTAssertEqual(ClassAnalytics.loggedEvents[0].parameters!["price"] as! Double, 9.99)
        }
    }
    
    func testInstanceProvider() {
        let provider = InstanceProvider()
        provider.log("purchase", parameters: ["product_id": 123, "price": 9.99])
        XCTAssertTrue(provider.cls === InstanceAnalytics.self)
        XCTAssertTrue(provider.instance === InstanceAnalytics.shared)
        XCTAssertEqual(provider.selector, #selector(InstanceAnalytics.logEvent(_:parameters:)))
        XCTAssertTrue(provider.responds)
        if InstanceAnalytics.shared.loggedEvents.count != 0{
        XCTAssertEqual(InstanceAnalytics.shared.loggedEvents[0].name, "purchase")
        XCTAssertEqual(InstanceAnalytics.shared.loggedEvents[0].parameters!["product_id"] as! Int, 123)
        XCTAssertEqual(InstanceAnalytics.shared.loggedEvents[0].parameters!["price"] as! Double, 9.99)
        }
    }
    
    func testRespondsReturnsFalseForUnknownClass() {
        let provider = InvalidProvider()
        XCTAssertNil(provider.cls)
        XCTAssertFalse(provider.responds)
    }
}
