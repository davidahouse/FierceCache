//
//  FierceCacheDelegateTests.swift
//  FierceCache
//
//  Created by David House on 7/3/15.
//  Copyright © 2015 David House. All rights reserved.
//

import XCTest
import FierceCache

class FierceCacheMockDelegate : FierceCacheProviderDelegate {
    
    var insertPath:String?
    var insertObject:Any?
    var updatePath:String?
    var updateObject:Any?
    var deletePath:String?
    var deleteObject:Any?
    var getPath:String?
    var queryTag:String?

    func didInsert(key: String, object: Any?) {
        self.insertPath = key
        self.insertObject = object
    }
    
    func didUpdate(key: String, object: Any?) {
        self.updatePath = key
        self.updateObject = object
    }
    
    func didDelete(key: String, object: Any?) {
        self.deletePath = key
        self.deleteObject = object
    }
    
    func didGet(key: String) {
        self.getPath = key
    }
    
    func didQuery(tag: String) {
        self.queryTag = tag
    }
}


class FierceCacheDelegateTests: XCTestCase {

    var cache:FierceCache = FierceCache()
    var cacheDelegate:FierceCacheMockDelegate = FierceCacheMockDelegate()
    
    override func setUp() {
        super.setUp()
        cache.delegate = cacheDelegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDelegateOnInsert() {
        
        let payload = "This is a test payload going into the cache"
        cache.set("/strings/1", object:payload)
        if let insertPath = cacheDelegate.insertPath {
            XCTAssertEqual(insertPath, "/strings/1")
        }
        else {
            XCTFail("insertPath not set")
        }
        
        if let insertPayload = cacheDelegate.insertObject as? String {
            XCTAssertEqual(insertPayload, payload)
        }
        else {
            XCTFail("insertObject not set")
        }
    }
    
    func testDelegateOnUpdate() {
        
        let payload = "This is a test payload going into the cache"
        cache.set("/strings/1", object:payload)
        if let insertPath = cacheDelegate.insertPath {
            XCTAssertEqual(insertPath, "/strings/1")
        }
        else {
            XCTFail("insertPath not set")
        }
        
        if let insertPayload = cacheDelegate.insertObject as? String {
            XCTAssertEqual(insertPayload, payload)
        }
        else {
            XCTFail("insertObject not set")
        }
        
        let updatedPayload = "This is the updated data"
        cache.set("/strings/1", object: updatedPayload)
        if let updatePath = cacheDelegate.updatePath {
            XCTAssertEqual(updatePath, "/strings/1")
        }
        else {
            XCTFail("updatePath not set")
        }
        
        if let updatePayload = cacheDelegate.updateObject as? String {
            XCTAssertEqual(updatePayload, updatedPayload)
        }
        else {
            XCTFail("updateObject not set")
        }
    }
    
    func testDelegateOnDelete() {
        
        let payload = "This is a test payload going into the cache"
        cache.set("/strings/1", object:payload)
        if let insertPath = cacheDelegate.insertPath {
            XCTAssertEqual(insertPath, "/strings/1")
        }
        else {
            XCTFail("insertPath not set")
        }
        
        if let insertPayload = cacheDelegate.insertObject as? String {
            XCTAssertEqual(insertPayload, payload)
        }
        else {
            XCTFail("insertObject not set")
        }

        cache.set("/strings/1", object: nil)
        if let deletePath = cacheDelegate.deletePath {
            XCTAssertEqual(deletePath, "/strings/1")
        }
        else {
            XCTFail("deletePath not set")
        }
        
        if let deletePayload = cacheDelegate.deleteObject as? String {
            XCTAssertEqual(deletePayload, payload)
        }
        else {
            XCTFail("deleteObject not set")
        }
        
    }
    
    func testDelegateOnGet() {
        
        let stuff = ["first one", "second one", "third", "fourth"]
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            cache.set("/things/\(i)", object: thing)
        }

        cache.get("/things/1")
        
        if let queryPath = cacheDelegate.getPath {
            XCTAssertEqual(queryPath, "/things/1")
        }
        else {
            XCTFail("get path not set")
        }
    }
    
    // FIXME:
//    func testDelegateOnQuery() {
//        
//        let stuff = ["first one", "second one", "third", "fourth"]
//        
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//        
//        cache.query("/things")
//        
//        if let queryPath = cacheDelegate.queryPath {
//            XCTAssertEqual(queryPath, ["/things"])
//        }
//        else {
//            XCTFail("query path not set")
//        }
//    }
//
//    func testDelegateOnQueryFilter() {
//        
//        let stuff = ["first one", "second one", "third", "fourth"]
//        
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//        
//        cache.query("/things",filter:{ (path:String,value:Any) -> Bool in
//            path.hasSuffix("1")
//        })
//        
//        if let queryPath = cacheDelegate.queryPath {
//            XCTAssertEqual(queryPath, ["/things"])
//        }
//        else {
//            XCTFail("query path not set")
//        }
//    }

}
