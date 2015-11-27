//
//  FierceCacheNotificationTests.swift
//  FierceCache
//
//  Created by David House on 7/1/15.
//  Copyright © 2015 David House. All rights reserved.
//

import XCTest

class FierceCacheNotificationTests: XCTestCase {
    
    var cache:FierceCache = FierceCache()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInsertNotification() {
        
        let handler : XCNotificationExpectationHandler = { notification in
         
            if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {
                
                print("notification for \(details.key)")
                
                if details.type != .Insert {
                    return false
                }
                
                if details.key != "strings_1" {
                    return false
                }
                
                if let payloadString = details.object as? String {
                    if payloadString == "This is a test payload going into the cache" {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else {
                    return false
                }
            }
            return false
        }
        
        self.expectationForNotification("FierceCacheNotification_strings_1", object: nil, handler: handler)
        
        let payload = "This is a test payload going into the cache"
        cache.set("strings_1", object:payload)
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testUpdateNotification() {
        
        let handler : XCNotificationExpectationHandler = { notification in
            
            if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {
                
                print("notification for \(details.key)")
                
                if details.type != .Update {
                    return false
                }
                
                if details.key != "strings_update" {
                    return false
                }
                
                if let payloadString = details.object as? String {
                    if payloadString == "Here is the newer string" {
                        return true
                    }
                    else {
                        return false
                    }
                }
                else {
                    return false
                }
            }
            return false
        }
        
        self.expectationForNotification("FierceCacheNotification_strings_update", object: nil, handler: handler)
        
        let payload = "This is the initial string"
        cache.set("strings_update", object: payload)
        
        if let result = cache.get("strings_update") as? String {
            XCTAssertEqual(result, payload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
        
        let newPayload = "Here is the newer string"
        cache.set("strings_update", object: newPayload)
        
        if let result = cache.get("strings_update") as? String {
            XCTAssertEqual(result, newPayload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

    func testDeleteNotification() {
        
        let handler : XCNotificationExpectationHandler = { notification in
            
            if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {
                
                print("notification for \(details.key)")
                
                if details.type != .Delete {
                    return false
                }
                
                if details.key != "strings_delete" {
                    return false
                }
                
                if details.object != nil {
                    return true
                }
                else {
                    return false
                }
            }
            return false
        }
        
        self.expectationForNotification("FierceCacheNotification_strings_delete", object: nil, handler: handler)
        
        let payload = "This is the initial string"
        cache.set("strings_delete", object: payload)
        
        if let result = cache.get("strings_delete") as? String {
            XCTAssertEqual(result, payload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
        
        cache.set("strings_delete", object: nil)
        if let result = cache.get("strings_delete") as? String {
            XCTFail("cache returned something, but it was supposed to be deleted. returned \(result)")
        }

        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
