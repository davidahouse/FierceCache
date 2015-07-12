# FierceCache
A cache written in Swift.

NOTE: This is still very much a work in progress. Classes & protocol interfaces are very likely to change in the next few releases.

## Features

- Ability to store any Swift class or struct
- Simple methods to get/set values
- Path system for cache organization
- Binding mechanism
- Delegate protocol for persisting and loading cache

## Requirements

- iOS 7.0+ / Mac OS X 10.9+
- Xcode 7

## Installation

CocoaPods and Carthage support coming soon (Carthage may just work, I haven't tested it yet). Otherwise simply add the FierceCache project to your workspace and set the FierceCache as a framework reference.

---

## Usage

### Adding values to the cache

To insert or update a value in the cache, use the set method. The path is completely arbitrary, but by using some kind of logical scheme you can easily get data out of the cache at any level of the path.

```swift
import FierceCache

var cache = FierceCache()
cache.set("/stuff/1","Store a basic string")
```

Also you can add multiple things at a time, but each one needs to be a tuple of a path and the object.

```swift
let stuff:[(String,Any?)] = [("/things/1","first one"),("/things/2","second one"),("/things/3","third"),("/things/4","fourth")]
cache.set(stuff)
```

### Retrieving from the cache

To get a single item from the cache, use get.

```swift
if let aString = cache.get("/stuff/1") as? String {
  print("found it! \(aString)")
}
```

Note that the get method returns an Any?, but it is easy to use the if let as? syntax to ensure the item was found in the cache AND it is type you expect.

To get multiple values from the cache, use query.

```swift
let foundStuff = cache.query("/things")
```

Query returns an array with anything matching the path (anything directly on the path or anything below it). The array contains a tuple containing a path & object for each item found.

To get only certain objects in a query, use filter! (aka: Swift is cool)

```swift
let foundStuff = cache.query("/things",filter:{ (path:String,value:Any) -> Bool in
            path.hasSuffix("1")
        })
```

Look at the tests in FierceCacheBasicTests for more examples and how to deal with query returning heterogeneous results.

### Bindings

The bindings mechanism provides a powerful way to build applications. This adds a separation of concerns between the controllers and the source of the model data. To use the binding system, use the bind method on the cache to create a binding object that watches for data on a certain path (or its children).

```swift
var binder = cache.bind("/things")
```

Once you have created a binder, there are several ways to be notified of cache changes. The basic operations of insert, update and delegate are covered in three different properties.

```swift
binder.onInsert = { (path:String,object:Any) in
  if let result = object as? String {
    print("something was added! /(result)")
  }
}

binder.onUpdate = { (path:String,object:Any) in
  if let result = object as? String {
    print("something was updated! /(result)")
  }
}

binder.onDelete = { (path:String,object:Any) in
  if let result = object as? String {
    print("something was deleted! /(result)")
  }
}
```

If you just want to get updated with the state of the cache when the binding is made, and then any future changes, use the onGet and onQuery methods (depending on if you want one thing or multiple). Note that onGet and onQuery may be called immediately if the cache contains anything matching the path, while still being called at a later time if the cache changes at that path.

```swift
binder.onGet = { (path:String,object:Any?,type:FierceCacheNotificationType) in
  if result = object as? String {
    // do something with the string in the UI
  }
  else {
    // item was deleted from the cache so update UI
  }
}

binder.onQuery = { (objects:[(String,Any)],type:FierceCacheNotificationType) in
  // array contains our objects, while type lets us know the operation that caused
  // this to be called
}
```

### Delegate

Assigning a delegate to the cache allows you to be notified directly for any changes in the cache without having to bind to a specific path. The delegate has to implement the FierceCacheProviderDelegate protocol.

```swift
cache.delegate = self
```

The delegate gets notified for any insert, update, delete in the cache as well as any get or query. This delegate can be used to add persistence to the cache, or to build a provider that can load data after someone has asked for it.

## License

FierceCache is released under the MIT license. See LICENSE for details.
