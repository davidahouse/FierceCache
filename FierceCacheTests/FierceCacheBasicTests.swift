//
//  FierceCacheTests.swift
//  FierceCacheTests
//
//  Created by David House on 7/1/15.
//  Copyright © 2015 David House. All rights reserved.
//

import XCTest

struct StructTest {
    let name:String
    let title:String
    
    init(name:String,title:String) {
        self.name = name
        self.title = title
    }
}

class ClassTest {
    let name:String
    let title:String
    
    init(name:String,title:String) {
        self.name = name
        self.title = title
    }
}


class FierceCacheBasicTests: XCTestCase {
    
    var cache:FierceCache = FierceCache()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetAndGet() {
        
        let payload = "This is a test payload going into the cache"
        cache.set("string_1", object:payload)
        
        if let result = cache.get("string_1") as? String {
            XCTAssertEqual(result, payload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
    }
    
    func testUpdate() {
        
        let payload = "This is the initial string"
        cache.set("string_update", object: payload)

        if let result = cache.get("string_update") as? String {
            XCTAssertEqual(result, payload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }

        let newPayload = "Here is the newer string"
        cache.set("string_update", object: newPayload)
        
        if let result = cache.get("string_update") as? String {
            XCTAssertEqual(result, newPayload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
    }
    
    func testDelete() {
        
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
    }
    
    func testGetCasting() {
        
        let payload = "This is a test payload going into the cache"
        cache.set("strings_string", object:payload)

        if let result = cache.get("strings_string") as? Int {
            XCTFail("cache returned something and cast it to an Int, but it should be a string. result: \(result)")
        }
    }
    
    func testSetAndGetMultipleThings() {
        
        let stuff = ["first one", "second one", "third", "fourth"]
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            cache.set("things_\(i)", object: thing)
        }
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            if let result = cache.get("things_\(i)") as? String {
                XCTAssertEqual(result, thing, "Cache returned something unexpected")
            }
        }
    }
    
    func testGetInvalidPath() {

        let payload = "This is a test payload going into the cache"
        cache.set("strings_1", object:payload)

        if let result = cache.get("strings_X") as? String {
            XCTFail("cache returned something but the path was invalid. result: \(result)")
        }
    }
    
    func testStoreStruct() {
     
        let myStruct = StructTest(name: "fred", title: "rock crusher")
        cache.set("fred",object: myStruct)
    
        if let result = cache.get("fred") as? StructTest {
            XCTAssertEqual(result.name, myStruct.name)
            XCTAssertEqual(result.title, myStruct.title)
        }
    }
    
    func testStoreClass() {
        
        let myClass = ClassTest(name: "fred", title: "rock crusher")
        cache.set("fred",object: myClass)
        
        if let result = cache.get("fred") as? ClassTest {
            XCTAssertEqual(result.name, myClass.name)
            XCTAssertEqual(result.title, myClass.title)
        }
    }
    
    func testMultiSet() {
        
        let stuff:[(String,Any?)] = [("thing_1","first one"),("thing_2","second one"),("thing_3","third"),("thing_4","fourth")]
        cache.set(stuff)

        for ( var i = 1; i <= stuff.count; i++ ) {
            let thing = stuff[i-1]
            if let thing_string = thing.1 as? String {
                if let result = cache.get("thing_\(i)") as? String {
                    XCTAssertEqual(result, thing_string, "Cache returned something unexpected")
                }
            }
        }
    }
    
    func testQuery() {
        
        let stuff = ["first one", "second one", "third", "fourth"]
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            cache.set("thing_\(i)", object: thing, tags:["things"])
        }
        
        let foundStuff = cache.query("things")
        XCTAssertEqual(stuff.count, foundStuff.count,"Query returned the wrong number of records")
        for (path,object) in foundStuff {
            XCTAssertNotNil(path)
            if let thing = object as? String {
                XCTAssertTrue(stuff.contains(thing))
            }
            else {
                XCTFail()
            }
        }
    }
    
    func testQueryWithHeterogeneousContents() {
        
        let stuff:Array<Any> = ["first one", "second one", StructTest(name: "fred", title: "rock crucsher"), ClassTest(name: "barney", title: "whatever")]
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            cache.set("things\(i)", object: thing, tags:["things"])
        }
        
        let foundStuff = cache.query("things")
        XCTAssertEqual(stuff.count, foundStuff.count,"Query returned the wrong number of records")
        
        let foundStrings = foundStuff.filter { (path:String,object:Any) -> Bool in
            return object.dynamicType == String.self
        }
        XCTAssertTrue(foundStrings.count == 2,"Didn't filter out 2 strings")
        
        let foundStructs = foundStuff.filter { (path:String,object:Any) -> Bool in
            return object.dynamicType == StructTest.self
        }
        XCTAssertTrue(foundStructs.count == 1,"Didn't filter out 1 structs")

        let foundInt = foundStuff.filter { (path:String,object:Any) -> Bool in
            return object.dynamicType == Int.self }
        XCTAssertTrue(foundInt.count == 0,"Should have 0 Ints, but it found more?")
    }
    
    func testQueryOnInvalidPath() {
        
        let stuff = ["first one", "second one", "third", "fourth"]
        
        for ( var i = 0; i < stuff.count; i++ ) {
            let thing = stuff[i]
            cache.set("things\(i)", object: thing, tags:["thing"])
        }
        
        let foundStuff = cache.query("nothings")
        XCTAssertTrue(foundStuff.count == 0)
    }
    
    func testQueryFromMultiSet() {
        
        let stuff:[(String,Any?,[String])] = [("thing_1","first one",["things"]),("thing_2","second one",["things"]),("thing_3","third",["things"]),("thing_4","fourth",["things"])]
        cache.set(stuff)
        
        let foundStuff = cache.query("things")
        XCTAssertEqual(stuff.count, foundStuff.count,"Query returned the wrong number of records")
    }

    func testQueryAfterDelete() {
        
        let payload = "This is the initial string"
        cache.set("strings_delete", object: payload, tags:["strings"])
        
        if let result = cache.get("strings_delete") as? String {
            XCTAssertEqual(result, payload,"Cache returned something but wasn't the same as what we put in")
        }
        else {
            XCTFail("cache returned a nil object, but it should have been there")
        }
        
        let foundStuff = cache.query("strings")
        XCTAssertEqual(foundStuff.count,1,"Query didn't return 1 row")
        
        cache.set("strings_delete", object: nil)
        if let result = cache.get("strings_delete") as? String {
            XCTFail("cache returned something, but it was supposed to be deleted. returned \(result)")
        }

        let foundStuffAfterDelete = cache.query("strings")
        XCTAssertEqual(foundStuffAfterDelete.count,0,"Query didn't return 1 row")
    }
    
//    func testQueryWithFilter() {
//
//        let stuff = ["first one", "second one", "third", "fourth"]
//        
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//    
//        let foundStuff = cache.query("/things",filter:{ (path:String,value:Any) -> Bool in
//            path.hasSuffix("1")
//        })
//        XCTAssertTrue(foundStuff.count == 1)
//    }
//    
//    func testQueryWithComplexFilter() {
//        
//        let stuff:Array<Any> = ["first one", "second one", StructTest(name: "fred", title: "rock crucsher"), StructTest(name:"wilma", title: "saint"), ClassTest(name: "barney", title: "whatever")]
//        
//        for ( var i = 0; i < stuff.count; i++ ) {
//            let thing = stuff[i]
//            cache.set("/things/\(i)", object: thing)
//        }
//        
//        let foundStuff = cache.query("/things",filter:{ (path:String,value:Any) -> Bool in
//            if let structVal:StructTest = value as? StructTest {
//                if structVal.name == "wilma" {
//                    return true
//                }
//                else {
//                    return false
//                }
//            }
//            else {
//                return false
//            }
//        })
//        XCTAssertTrue(foundStuff.count == 1)
//    }
}
