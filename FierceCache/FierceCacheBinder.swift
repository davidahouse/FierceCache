//
//  FierceCacheBinder.swift
//
//  Created by David House on 7/1/15.
//  Copyright © 2015 David House. All rights reserved.
//

import Foundation

public typealias fierceBinderNotify = (String,Any) -> ()

// MARK: FierceCacheBinder
public class FierceCacheBinder {
    
    let cache:FierceCache
    let key:String
    let queue:NSOperationQueue
    public var onInsert:fierceBinderNotify?
    public var onUpdate:fierceBinderNotify?
    public var onDelete:fierceBinderNotify?

    init(cache:FierceCache,key:String) {
        self.cache = cache
        self.key = key
        self.queue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBindings:", name: "FierceCacheNotification_\(key)", object: nil)
    }

    init(cache:FierceCache,key:String,queue:NSOperationQueue) {
        self.cache = cache
        self.key = key
        self.queue = queue
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBindings:", name: "FierceCacheNotification_\(key)", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Private Functions
    @objc func updateBindings(notification:NSNotification) {

        if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {

            if let notify = self.onInsert {
                if details.type == .Insert {
                    if let safeObject:Any = details.object {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(details.key!,safeObject)
                        })
                    }
                }
            }

            if let notify = self.onUpdate {
                if details.type == .Update {
                    if let safeObject:Any = details.object {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(details.key!,safeObject)
                        })
                    }
                }
            }
            
            if let notify = self.onDelete {
                if details.type == .Delete {
                    if let safeObject:Any = details.object {
                        self.queue.addOperationWithBlock({ () -> Void in
                            notify(details.key!,safeObject)
                        })
                    }
                }
            }

        }
    }
}