//
//  FierceCache.swift
//
//  Created by David House on 6/30/15.
//  Copyright © 2015 David House. All rights reserved.
//

import Foundation

// MARK: FierceCache notitifications
public enum FierceCacheNotificationType {
    case Insert
    case Delete
    case Update
    case Existing
}

public class FierceCacheNotification {
    let type:FierceCacheNotificationType
    let object:Any?
    let key:String?
    let tag:String?
    
    init(type:FierceCacheNotificationType,key:String,object:Any?) {
        self.type = type
        self.key = key
        self.object = object
        self.tag = nil
    }
    
    init(type:FierceCacheNotificationType,tag:String,object:Any?) {
        self.type = type
        self.tag = tag
        self.object = object
        self.key = nil
    }
}

// MARK: FierceCacheItem
struct FierceCacheItem {
    
    var key: String
    var createTime: NSDate
    var updateTime: NSDate?
    var object: Any
    
    init(key:String,object:Any) {
        self.key = key
        self.object = object
        self.createTime = NSDate()
        self.updateTime = nil
    }
    
    init(cacheItem:FierceCacheItem,object:Any) {
        self.key = cacheItem.key
        self.createTime = cacheItem.createTime
        self.updateTime = NSDate()
        self.object = object
    }
}

// MARK: FierceCacheQueryFilter
public typealias fierceCacheQueryFilter = (path:String,value:Any) -> Bool

// MARK: FierceCacheProviderDelegate
public protocol FierceCacheProviderDelegate {
    
    func didInsert(key:String,object:Any?)
    func didUpdate(key:String,object:Any?)
    func didDelete(key:String,object:Any?)
    func didGet(key:String)
    func didQuery(tag:String)
}


// MARK: FierceCache class
public class FierceCache {
    
    var tags:Dictionary<String,Array<String>> = Dictionary<String,Array<String>>()
    var contents:Dictionary<String,FierceCacheItem> = Dictionary<String,FierceCacheItem>()
    
    var delegate:FierceCacheProviderDelegate?
    
    public init() {
        
    }
    
    // MARK: Public methods
    public func get(key:String) -> Any? {
        
        print("[FierceCache get] \(key)")
        
        if let delegate = delegate {
            delegate.didGet(key)
        }

        if let item = contents[key] {
            return item.object
        }
        else {
            return nil
        }
    }
   
    public func set(key:String,object:Any?) {
        set(key, object: object, tags: [])
    }
    
    public func set(key:String,object:Any?,tags:[String]) {
        
        print("[FierceCache set] \(key)")

        if let object = object {
            
            if let item = contents[key] {
                // update
                contents[key] = FierceCacheItem(cacheItem: item,object: object)
                updateTags(key,tags:tags)
                
                self.propogateNotifications(key, tags:tags, notification: FierceCacheNotification(type: .Update, key: key, object: object))
                if let delegate = self.delegate {
                    delegate.didUpdate(key, object: object)
                }
            }
            else {
                // insert
                contents[key] = FierceCacheItem(key: key, object: object)
                insertTags(key,tags:tags)
                
                self.propogateNotifications(key, tags: tags, notification: FierceCacheNotification(type: .Insert, key: key, object: object))
                if let delegate = self.delegate {
                    delegate.didInsert(key, object: object)
                }
            }
        }
        else {
            
            if contents[key] != nil {
                // delete
                let deletedInTags = deleteTags(key)
                if let deletedObject = contents[key] {
                    contents.removeValueForKey(key)
                    self.propogateNotifications(key, tags: deletedInTags, notification: FierceCacheNotification(type: .Delete, key: key, object: deletedObject.object))
                    if let delegate = self.delegate {
                        delegate.didDelete(key, object: deletedObject.object)
                    }
                }
                else {
                    self.propogateNotifications(key, tags: deletedInTags, notification: FierceCacheNotification(type: .Delete, key: key, object: nil))
                    if let delegate = self.delegate {
                        delegate.didDelete(key, object:nil)
                    }
                }
                contents[key] = nil
            }
        }
    }
    
    public func set(objects:[(String,Any?)]) {
        
        for (key,object) in objects {
            self.set(key, object: object)
        }
    }

    public func set(objects:[(String,Any?,[String])]) {
        
        for (key,object,tags) in objects {
            self.set(key, object: object, tags:tags)
        }
    }

    public func query(tag:String) -> Array<(String,Any)> {
        
        if let delegate = delegate {
            delegate.didQuery(tag)
        }
        
        if let tagArray = tags[tag] {
            return contents.filter{ (key:String,value:FierceCacheItem) -> Bool in
                tagArray.contains(key)
                }.map({($0,$1.object)})
        }
        else {
            return Array<(String,Any)>()
        }
        
        
        
//        let found = contents.filter{ (key:String,value:FierceCacheItem) -> Bool in
//            key.hasPrefix(path)
//        }
        // FIXME:
        //        return found.map({($0.1.path,$0.1.object)})
    }
    
//    public func query(path:String,filter:fierceCacheQueryFilter) -> Array<(String,Any)> {
//
//        if let delegate = delegate {
//            delegate.didQuery([path])
//        }
//
//        let found = contents.filter({ (key:String,value:FierceCacheItem) -> Bool in
//            return key.hasPrefix(path) && filter(path: key, value: value.object)
//        })
//        // FIXME:
//        // return found.map({($0.1.path,$0.1.object)})
//        return Array<(String,Any)>()
//    }
    
    public func bind(key:String) -> FierceCacheBinder {
        
        let binder = FierceCacheBinder(cache: self, key: key)
        return binder
    }
    
    public func bindTag(tag:String) -> FierceCacheTagBinder {
        
        let binder = FierceCacheTagBinder(cache: self, tag: tag)
        return binder
    }
    
    public func emptyCache() {
        
        // toast anything in the cache
        self.contents = Dictionary<String,FierceCacheItem>()
    }
    
    // MARK: Private Methods
    private func propogateNotifications(key:String,tags:[String],notification:FierceCacheNotification) {
        
        if key.characters.count <= 1 {
            return
        }
        
        print("Notify: \(key)")
        var notifyInfo = Dictionary<NSObject,AnyObject>()
        notifyInfo["notification"] = notification
        NSNotificationCenter.defaultCenter().postNotificationName("FierceCacheNotification_\(key)", object: nil, userInfo:notifyInfo)
        
        for tag in tags {
            let tagNotification = FierceCacheNotification(type: notification.type, tag: tag, object: notification.object)
            var tagNotifyInfo = Dictionary<NSObject,AnyObject>()
            tagNotifyInfo["notification"] = tagNotification
            NSNotificationCenter.defaultCenter().postNotificationName("FierceCacheNotification_Tag_\(tag)", object: nil, userInfo:tagNotifyInfo)
        }
    }
    
    private func updateTags(key:String,tags:[String]) {
        // Check each tag to make sure it is set
        for tag in tags {
            if var tagArray = self.tags[tag] {
                if !tagArray.contains(key) {
                    tagArray.append(key)
                    self.tags[tag] = tagArray
                }
            }
            else {
                var tagArray = [String]()
                tagArray.append(key)
                self.tags[tag] = tagArray
            }
        }
        
        // Now painful part is to see if this object is tagged anywhere else
        for (tag,_) in self.tags {
            if var tagArray = self.tags[tag] {
                if !tags.contains(tag) {
                    if let index = tagArray.indexOf(key) {
                        tagArray.removeAtIndex(index)
                    }
                }
            }
        }
    }
    
    private func insertTags(key:String,tags:[String]) {
        // Check each tag to make sure it is set
        for tag in tags {
            if var tagArray = self.tags[tag] {
                if !tagArray.contains(key) {
                    tagArray.append(key)
                    self.tags[tag] = tagArray
                }
            }
            else {
                var tagArray = [String]()
                tagArray.append(key)
                self.tags[tag] = tagArray
            }
        }
    }
    
    private func deleteTags(key:String) -> [String] {
        var deletedIn = [String]()
        for (tag,_) in self.tags {
            if var tagArray = self.tags[tag], let index = tagArray.indexOf(key) {
                deletedIn.append(tag)
                tagArray.removeAtIndex(index)
            }
        }
        return deletedIn
    }
}

