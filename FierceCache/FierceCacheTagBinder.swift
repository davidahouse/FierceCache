//
//  FierceCacheTagBinder.swift
//  FierceCache
//
//  Created by David House on 9/19/15.
//  Copyright © 2015 David House. All rights reserved.
//

import Foundation

public typealias fierceTagBinderNotify = ([(String,Any)],FierceCacheNotificationType) -> ()

// MARK: FierceCacheBinder
public class FierceCacheTagBinder {
    
    let cache:FierceCache
    let tag:String
    let queue:NSOperationQueue
    public var onInsert:fierceTagBinderNotify?
    public var onUpdate:fierceTagBinderNotify?
    public var onDelete:fierceTagBinderNotify?
    
    init(cache:FierceCache,tag:String) {
        self.cache = cache
        self.tag = tag
        self.queue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBindings:", name: "FierceCacheNotification_Tag_\(tag)", object: nil)
    }

    init(cache:FierceCache,tag:String,queue:NSOperationQueue) {
        self.cache = cache
        self.tag = tag
        self.queue = queue
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBindings:", name: "FierceCacheNotification_Tag_\(tag)", object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private Functions
    @objc func updateBindings(notification:NSNotification) {
        
        if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {
            
            if let notify = self.onInsert {
                if details.type == .Insert {
                    if let result:Array<(String,Any)> = self.cache.query(details.tag!) {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(result,details.type)
                        })
                    }
                }
            }
            
            if let notify = self.onUpdate {
                if details.type == .Update {
                    if let result:Array<(String,Any)> = self.cache.query(details.tag!) {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(result,details.type)
                        })
                    }
                }
            }
            
            if let notify = self.onDelete {
                if details.type == .Delete {
                    if let result:Array<(String,Any)> = self.cache.query(details.tag!) {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(result,details.type)
                        })
                    }
                }
            }
        }
    }
}