# FierceCache CHANGELOG

## 0.0.2

Added an Existing notification type and now onGet and onQuery will be triggered immediately if
there is matching data in the cache.

The onGet callback will now be triggered on a cache delete, but the object passed in will be nil.

## 0.0.1

Initial release. Ready for testing but still needs documentation and example application.
