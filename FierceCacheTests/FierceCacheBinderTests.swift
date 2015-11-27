//
//  FierceCacheBinderTests.swift
//  FierceCache
//
//  Created by David House on 7/1/15.
//  Copyright © 2015 David House. All rights reserved.
//

import XCTest

class FierceCacheBinderTests: XCTestCase {

    var cache:FierceCache = FierceCache()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testOnInsert() {
    
        let expectation = self.expectationWithDescription("Expect notify closure is called")
        
        let binder = cache.bind("strings_1")
        binder.onInsert = { (path:String,object:Any) in
         
            if let result = object as? String {
                if result == "This is a test payload going into the cache" {
                    expectation.fulfill()
                }
            }
        }
        
        let payload = "This is a test payload going into the cache"
        cache.set("strings_1", object:payload)
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testOnUpdate() {
        
        let expectation = self.expectationWithDescription("Expect notify closure is called")
        
        let binder = cache.bind("strings_1")
        binder.onUpdate = { (path:String,object:Any) in
            
            if let result = object as? String {
                if result == "This is the updated payload" {
                    expectation.fulfill()
                }
            }
        }
        
        let payload = "This is a test payload going into the cache"
        cache.set("strings_1", object:payload)
        
        let payloadUpdated = "This is the updated payload"
        cache.set("strings_1", object:payloadUpdated)
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testOnDelete() {
        
        let expectation = self.expectationWithDescription("Expect notify closure is called")
        
        let binder = cache.bind("strings_1")
        binder.onDelete = { (path:String,object:Any) in
            
            if let result = object as? String {
                if result == "This is a test payload going into the cache" {
                    expectation.fulfill()
                }
            }
        }
        
        let payload = "This is a test payload going into the cache"
        cache.set("strings_1", object:payload)
        cache.set("strings_1", object:nil)
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
//    func testOnGetFromInsert() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings/1")
//        binder.onGet = { (path:String,object:Any?,type:FierceCacheNotificationType) in
//        
//            if type == .Insert {
//                if path == "/strings/1" {
//                    if let result = object as? String {
//                        if result == "This is a test payload going into the cache" {
//                            expectation.fulfill()
//                        }
//                    }
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnGetFromUpdate() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings/1")
//        binder.onGet = { (path:String,object:Any?,type:FierceCacheNotificationType) in
//            
//            if type == .Update {
//                if path == "/strings/1" {
//                    if let result = object as? String {
//                        if result == "This is the updated payload" {
//                            expectation.fulfill()
//                        }
//                    }
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        
//        let payloadUpdated = "This is the updated payload"
//        cache.set("/strings/1", object:payloadUpdated)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnGetFromDelete() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings/1")
//        binder.onGet = { (path:String,object:Any?,type:FierceCacheNotificationType) in
//            
//            if type == .Delete {
//                if path == "/strings/1" {
//                    if object == nil {
//                        expectation.fulfill()
//                    }
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        cache.set("/strings/1", object:nil)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnQuery() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//
//        let binder = cache.bind("/things")
//        binder.onQuery = { (objects:[(String,Any)],notification:FierceCacheNotificationType) in
//
//            if objects.count == 4 {
//                expectation.fulfill()
//            }
//
//        }
//
//        let stuff = ["first one", "second one", "third", "fourth"]
//
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnInsertPropagate() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings")
//        binder.onInsert = { (path:String,object:Any) in
//            
//            if let result = object as? String {
//                if result == "This is a test payload going into the cache" {
//                    expectation.fulfill()
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnUpdatePropagate() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings")
//        binder.onUpdate = { (path:String,object:Any) in
//            
//            if let result = object as? String {
//                if result == "This is the updated payload" {
//                    expectation.fulfill()
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        
//        let payloadUpdated = "This is the updated payload"
//        cache.set("/strings/1", object:payloadUpdated)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnDeletePropagate() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//        
//        let binder = cache.bind("/strings")
//        binder.onDelete = { (path:String,object:Any) in
//            
//            if let result = object as? String {
//                if result == "This is a test payload going into the cache" {
//                    expectation.fulfill()
//                }
//            }
//        }
//        
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//        cache.set("/strings/1", object:nil)
//        
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    func testOnGetWithExisting() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//
//        let payload = "This is a test payload going into the cache"
//        cache.set("/strings/1", object:payload)
//
//        let binder = cache.bind("/strings/1")
//        binder.onGet = { (path:String,object:Any?,type:FierceCacheNotificationType) in
//            
//            if type == .Existing {
//                if path == "/strings/1" {
//                    if let result = object as? String {
//                        if result == "This is a test payload going into the cache" {
//                            expectation.fulfill()
//                        }
//                    }
//                }
//            }
//        }
//
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
//    
//    
//    func testOnQueryWithExisting() {
//        
//        let expectation = self.expectationWithDescription("Expect notify closure is called")
//
//        let stuff = ["first one", "second one", "third", "fourth"]
//        
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//        
//        let binder = cache.bind("/things")
//        binder.onQuery = { (objects:[(String,Any)],notification:FierceCacheNotificationType) in
//            
//            if objects.count == 4 {
//                expectation.fulfill()
//            }
//            
//        }
//    
//        self.waitForExpectationsWithTimeout(5.0, handler: nil)
//    }
}
