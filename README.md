# RAD-iOS

## RAD 

### Podcast Analytics

Remote Audio Data is a framework for reporting the listenership of podcasts in iOS apps.

If you want to view the RAD specification in more detail, please visit [this page](https://docs.google.com/document/d/14W1M3RaNfv-3mzY0paTs1A_uZ5fITSvWbpMbIikdHxk).

## How to integrate RAD framework

### [Carthage](https://github.com/Carthage/Carthage)

Add RAD dependency in your Cartfile
```
github "npr/RAD-iOS"
```
and follow the [general flow](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos) to add the `RAD` and, its dependency, `Reachability` frameworks into your project.

### [CocoaPods](https://cocoapods.org)

Add `RAD` pod in your Podfile and execute `pod update` using the command line in your project directory.

Example:
```
target 'TargetName' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TargetName
  pod "RAD"
end
```

### Project integration

The RAD framework consists of a single class `Analytics` which provides support to start collecting data from an `AVPlayer` and send the data to Analytics servers.

Import the Swift module in the files which is used
```swift
import RAD
```

Within your business model create an instance of `Analytics`.
```swift
let analytics = Analytics()
```
Or you use a singleton if it is appropriate:
```swift
static let RADAnalytics = Analytics()
```
The Analytics object has a `configuration` property. By using this constructor, a default `Configuration` is used.
To see default values of [`Configuration`](RAD/RAD/Model/Entities/Configuration.swift), you can check the [`Analytics`](RAD/RAD/Analytics.swift) class.

A custom configuration may be passed to the `Analytics` instance via constructor.
```swift
let configuration = Configuration(
            submissionTimeInterval: TimeInterval.minutes(30), // how much time to wait until the stored events in the local storage are sent to analyics servers
            batchSize: 10, // how many events are send per network request
            expirationTimeInterval: DateComponents(day: 2), // how much time is an event valid
            sessionExpirationTimeInterval: TimeInterval.hours(24), // how much time is a session identifier active
            requestHeaderFields: [
               "UserAgent": "iPhone/iOS",
               "MyCustomKey": "CustomValue"] // header fields which will be added on each network request
)
let analytics = Analytics(configuration: configuration)
```

To start recording data, pass an instance of `AVPlayer` to the instance of `Analytics`. Upon creating the player it is required to no initialize with any item, otherwise that item will not be analyzed.
```swift
let player = AVPlayer(playerItem: nil) // intialize the player
analytics.observePlayer(player) // start observing
player.replaceCurrentItem(with: playerItem) // change current item
```

To provide support for sending data while application is in background, it is required to enable [Background Fetch](https://developer.apple.com/documentation/uikit/core_app/managing_your_app_s_life_cycle/preparing_your_app_to_run_in_the_background/updating_your_app_with_background_app_refresh) and override [application(\_:performFetchWithCompletionHandler:)](). Example:
```swift
func application(
     _ application: UIApplication,
     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
) {
     analytics.performBackgroundFetch(completion: completionHandler)
}
```

Sending data to the analytics servers may be stopped or started at anytime. By default, data is sent to the servers when the `Analytics` object is created. 

You can start and stop the data send using the following methods:
```swift
analytics.stopSendingData() // the next data send schedule is cancelled and data is not send to servers anymore
analytics.startSendingData() // schedule a point in time when to send data to servers based on configuration
```

## Demo

A demo project is available. Before first run, it is required to checkout its dependencies using Carthage
```
carthage update --platform iOS --cache-builds --no-use-binaries
```
