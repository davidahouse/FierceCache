//
//  FierceCacheBinder.swift
//  FierceCache
//
//  Created by David House on 7/1/15.
//  Copyright © 2015 David House. All rights reserved.
//

import Foundation

typealias fierceBinderGetNotify = (Any,FierceCacheNotificationType) -> ()
typealias fierceBinderQueryNotify = ([(String,Any)],FierceCacheNotificationType) -> ()
typealias fierceBinderNotify = (String,Any) -> ()

// MARK: FierceCacheBinder
class FierceCacheBinder {
    
    let cache:FierceCache
    let path:String
    var onInsert:fierceBinderNotify?
    var onUpdate:fierceBinderNotify?
    var onGet:fierceBinderGetNotify?
    var onQuery:fierceBinderQueryNotify?
    var onDelete:fierceBinderNotify?
    
    init(cache:FierceCache,path:String) {
        self.cache = cache
        self.path = path
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateBindings:", name: path, object: nil)
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
                        notify(details.path,safeObject)
                    }
                }
            }

            if let notify = self.onUpdate {
                if details.type == .Update {
                    if let safeObject:Any = details.object {
                        notify(details.path,safeObject)
                    }
                }
            }
            
            if let notify = self.onDelete {
                if details.type == .Delete {
                    if let safeObject:Any = details.object {
                        notify(details.path,safeObject)
                    }
                }
            }
            
            if let notify = self.onGet {
                if let result = self.cache.get(details.path) {
                    notify(result,details.type)
                }
            }
            
            if let notify = self.onQuery {
                if let userInfo = notification.userInfo, details = userInfo["notification"] as? FierceCacheNotification {
                    if let result:Array<(String,Any)> = self.cache.query(details.path) {
                        notify(result,details.type)
                    }
                }
            }
        }
    }
}