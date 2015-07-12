//
//  FierceCache.swift
//  BeShipping
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
    let path:String
    
    init(type:FierceCacheNotificationType,path:String,object:Any?) {
        self.type = type
        self.path = path
        self.object = object
    }
}

// MARK: FierceCacheItem
struct FierceCacheItem {
    
    var path: String
    var createTime: NSDate
    var updateTime: NSDate?
    var object: Any
    
    init(path:String,object:Any) {
        self.path = path
        self.object = object
        self.createTime = NSDate()
        self.updateTime = nil
    }
    
    init(cacheItem:FierceCacheItem,object:Any) {
        self.path = cacheItem.path
        self.createTime = cacheItem.createTime
        self.updateTime = NSDate()
        self.object = object
    }
}

// MARK: FierceCacheQueryFilter
public typealias fierceCacheQueryFilter = (path:String,value:Any) -> Bool

// MARK: FierceCacheProviderDelegate
public protocol FierceCacheProviderDelegate {
    
    func didInsert(path:String,object:Any?)
    func didUpdate(path:String,object:Any?)
    func didDelete(path:String,object:Any?)
    func didGet(path:String)
    func didQuery(path:String)
}


// MARK: FierceCache class
public class FierceCache {
    
    var contents:Dictionary<String,FierceCacheItem> = Dictionary<String,FierceCacheItem>()
    var delegate:FierceCacheProviderDelegate?
    
    public init() {
        
    }
    
    // MARK: Public methods
    public func get(path:String) -> Any? {
        
        print("[FierceCache get] \(path)")
        
        if let delegate = delegate {
            delegate.didGet(path)
        }

        if let item = contents[path] {
            return item.object
        }
        else {
            return nil
        }
    }
    
    public func set(path:String,object:Any?) {
        
        print("[FierceCache set] \(path)")

        if let object = object {
            
            if let item = contents[path] {
                // update
                contents[path] = FierceCacheItem(cacheItem: item,object: object)
                self.propogateNotifications(path, notification: FierceCacheNotification(type: .Update, path: path, object: object))
                if let delegate = self.delegate {
                    delegate.didUpdate(path, object: object)
                }
            }
            else {
                // insert
                contents[path] = FierceCacheItem(path: path, object: object)
                self.propogateNotifications(path, notification: FierceCacheNotification(type: .Insert, path: path, object: object))
                if let delegate = self.delegate {
                    delegate.didInsert(path, object: object)
                }
            }
        }
        else {
            
            if contents[path] != nil {
                // delete
                if let deletedObject = contents[path] {
                    self.propogateNotifications(path, notification: FierceCacheNotification(type: .Delete, path: path, object: deletedObject.object))
                    if let delegate = self.delegate {
                        delegate.didDelete(path, object: deletedObject.object)
                    }
                }
                else {
                    self.propogateNotifications(path, notification: FierceCacheNotification(type: .Delete, path: path, object: nil))
                    if let delegate = self.delegate {
                        delegate.didDelete(path, object:nil)
                    }
                }
                contents[path] = nil
            }
        }
    }
    
    public func set(objects:[(String,Any?)]) {
        
        for (path,object) in objects {
            self.set(path, object: object)
        }
    }
    
    public func query(path:String) -> Array<(String,Any)> {
        
        if let delegate = delegate {
            delegate.didQuery(path)
        }
        
        let found = contents.filter{ (key:String,value:FierceCacheItem) -> Bool in
            key.hasPrefix(path)
        }
        return found.map({($0.1.path,$0.1.object)})
    }
    
    public func query(path:String,filter:fierceCacheQueryFilter) -> Array<(String,Any)> {

        if let delegate = delegate {
            delegate.didQuery(path)
        }

        let found = contents.filter({ (key:String,value:FierceCacheItem) -> Bool in
            return key.hasPrefix(path) && filter(path: key, value: value.object)
        })
        return found.map({($0.1.path,$0.1.object)})
    }
    
    public func bind(path:String) -> FierceCacheBinder {
        
        let binder = FierceCacheBinder(cache: self, path: path)
        return binder
    }
    
    public func emptyCache() {
        
        // toast anything in the cache
        self.contents = Dictionary<String,FierceCacheItem>()
    }
    
    // MARK: Private Methods
    private func propogateNotifications(path:String,notification:FierceCacheNotification) {
        
        if path.characters.count <= 1 {
            return
        }
        
        print("Notify: \(path)")
        var notifyInfo = Dictionary<NSObject,AnyObject>()
        notifyInfo["notification"] = notification
        NSNotificationCenter.defaultCenter().postNotificationName(path, object: nil, userInfo:notifyInfo)
        
        let parentPath = path.stringByDeletingLastPathComponent
        if parentPath != "/" && parentPath.characters.count >= 1 {
            propogateNotifications(parentPath,notification:FierceCacheNotification(type: notification.type, path: parentPath, object: notification.object))
        }
    }
    
}