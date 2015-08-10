# FierceCache CHANGELOG

## 0.0.4

Fixed compiler problem with Beta 5. The path related methods/properties on a Swift string bridged to NSString are no longer directly available.

## 0.0.3

Added OSX target.
Added didGet method to delegate protocol.
Initial readme documentation.

## 0.0.2

Added an Existing notification type and now onGet and onQuery will be triggered immediately if
there is matching data in the cache.

The onGet callback will now be triggered on a cache delete, but the object passed in will be nil.

## 0.0.1

Initial release. Ready for testing but still needs documentation and example application.
