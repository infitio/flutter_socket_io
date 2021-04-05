## 1.0.0 - 3rd Apr, 2020

#### Breaking changes

* event listeners don't use callbacks anymore
* new syntax for listening to events:
```dart
final listener = socket.on('event-name').listen((data) => print(data));
```

* to cancel listening:
```dart
await listener.cancel();
```

##### Other major enhancements:

* Clear existing connections on hot-resart
* A new API is introduced: `await socket.connectSync()` will wait until a `connected`, or `conenctError` event is recieved and will accordingly resolve, or throw error.

##### Maintenance upgrades:

* Introducing codegen to generate constants for java, swift and dart to help reduce errors
* Add code linting rules to improvise flutter's auto formatting and code-readability
* Add integration tests
* Use Github Actions to
	* run lint checks
    * run integration tests on both Android and iOS emulators

## 0.4.2+1 - 27th May, 2020

* Fix for pub.dev to display support for iOS too. [See more](https://github.com/infitio/flutter_socket_io/pull/120#discussion_r429587289)

## 0.4.2 - 4th April, 2020

* [PR 120](https://github.com/infitio/flutter_socket_io/issues/120) Update Gradle Dependencies to latest available version (3.5.3) [@Saifallak](https://github.com/saifallak)

## 0.4.1 - 23rd October, 2019

Releasing PRs:

* [Expose method `isConnected` on socket interface](https://github.com/infitio/flutter_socket_io/pull/91)
* [Fix namespace issue for android](https://github.com/infitio/flutter_socket_io/pull/83)

## 0.4.0 - 8th September, 2019 [ **BREAKING CHANGE** ]

* AndroidX support

## 0.3.7 - 8th September, 2019

* Bug fix for [Stop listen event not working with one event #72](https://github.com/infitio/flutter_socket_io/issues/72)

## 0.3.6+1 - 8th September, 2019

* Formatting, and updating readme

## 0.3.6 - 8th September, 2019

* Lint fix for namespaces in Socket.io swift code.
* Show error when namespaces don't start with '/'
* namespace example added

## 0.3.5 - 29th August, 2019

* [PR63](https://github.com/infitio/flutter_socket_io/pull/63) Fix for clearing instances in case of multiple instances. by [Djo](https://github.com/rhessus)

## 0.3.4 - 26th August, 2019

* iOS SWIFT_VERSION bumped up to use 5.0 as defined by [Socket.IO-Client-Swift 15.1.0](https://github.com/CocoaPods/Specs/blob/master/Specs/6/2/4/Socket.IO-Client-Swift/15.1.0/Socket.IO-Client-Swift.podspec.json)

## 0.3.3+1 - 18th August, 2019

* [PR 57](https://github.com/infitio/flutter_socket_io/pull/57) fix for iOS (reqId wasn't optional) [@Saifallak](https://github.com/saifallak)

## 0.3.3 - 14th August, 2019

* Typo fix for nameSpace ( changed SocketOptions.namesapce to SocketOptions.nameSpace )

## 0.3.2 - 11th August, 2019

* ACK Bug fixes for android 27+ | UIThread/EventThread issue resolved

## 0.3.1 - 11th August, 2019

* Bug fixes from 0.3.0

## 0.3.0 - 11th August, 2019

### Bulk update
* [PR 18](https://github.com/infitio/flutter_socket_io/pull/18) - Update deployment target to 9.0 and allow for most recent version of Starscream
* [PR 27](https://github.com/infitio/flutter_socket_io/pull/27) - Android bug fix | Methods marked with @UiThread must be executed on the main thread
* [PR 35](https://github.com/infitio/flutter_socket_io/pull/35) - *ACK Support*
* [PR 44](https://github.com/infitio/flutter_socket_io/pull/44) - fix for duplicated listeners from platform channel
* [PR 45](https://github.com/infitio/flutter_socket_io/pull/45) - Bug Fix | Java class cast exception for timeout
* [PR 48](https://github.com/infitio/flutter_socket_io/pull/48) - Bug Fix | Swift version error on `pod install`
* [PR 52](https://github.com/infitio/flutter_socket_io/pull/52) - *Namespace support for iOS* | Any contributors can develop similarly for android

## 0.2.0 - 5th June, 2019

### Breaking Change
* Convert all arguments for SocketIOManager to a single Options object

old config
```
socket = await manager.createInstance(
  URI,
  query: {"auth": "--SOME AUTH STRING---",},
  enableLogging: false
);
```

new config

```
socket = await manager.createInstance(SocketOptions(
    URI,
    query: {"auth": "--SOME AUTH STRING---",},
    enableLogging: false,
));
```

* Introducing `transports` in SocketOptions

## 0.1.11 - 5th June, 2019
* BugFix: Methods marked with @UiThread must be executed on the main thread.
* Fix for https://github.com/infitio/flutter_socket_io/issues/8

## 0.1.10 - 26th February, 2019

* `clearInstance` BugFix on iOS

## 0.1.9 - 21st January, 2019

* BugFix for iOS running on iPhone 6

## 0.1.8 - 17th January, 2019

* Optimized serialization code for Android
* Bug fix for Map representation characters/reserved characters for map representation as a string (`=` and `/`)

## 0.1.7 - 17th January, 2019

* Disabling unnecessary logging of events in platform implementations in both Android and iOS,
can enable if required by passing `enableLogging: true` to `createInstance`

## 0.1.6 - 28th November, 2018

* Android and iOS data serialization handled properly to send objects and arrays

## 0.1.4 - 28th November, 2018

* Android query bug: Extra ? is being sent. fixed

## 0.1.3 - 21st November, 2018

* Added support for socket.io handshake query params for both iOS and Android

## 0.1.2 - 20th November, 2018

* Fully working version of basic Socket.io connection for both Android and iOS
