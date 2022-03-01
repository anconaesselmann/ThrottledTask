# ThrottledTask

[![CI Status](https://img.shields.io/travis/anconaesselmann/ThrottledTask.svg?style=flat)](https://travis-ci.org/anconaesselmann/ThrottledTask)
[![Version](https://img.shields.io/cocoapods/v/ThrottledTask.svg?style=flat)](https://cocoapods.org/pods/ThrottledTask)
[![License](https://img.shields.io/cocoapods/l/ThrottledTask.svg?style=flat)](https://cocoapods.org/pods/ThrottledTask)
[![Platform](https://img.shields.io/cocoapods/p/ThrottledTask.svg?style=flat)](https://cocoapods.org/pods/ThrottledTask)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Tutorial

`ThrottledTask` allows the creation of groups of tasks that will return together once the underlying work has completed. To further save resources a throttle window can be specified, during which new tasks will return a cached value of the completed work. In our example we'll be using `ThrottledTask` in the context of a networking layer.


We will be converting the following networking layer to use `ThrottledTask`.

We are using an `enum` to keep track of all possible API calls our app can make.

```swift
enum Request {
	case user(UUID)
	....

	var url: URL {
		switch self {
		case .user(let uuid): URL(stringValue: "api/user?id=\(uuidString)")!
		....
		}
	}
}
```

We have an `async/await` wrapper around the actual networking call that makes the request to our API and returns a response of the appropriate type for the request.

```swift
struct Networking {

    func fetch<Response>(_ request: Request) async throws -> Response where Response: Codable {
    	// The unthrottled networking request
    }
}
```

For our networking layer to adopt `ThrottledTask` we have to do a couple of things: Define how tasks should be grouped (1), keep track of what groups of tasks have been created (2), and decide how long to keep the results for those groups of tasks after the original task has been completed (4).


### 1) Grouping requests:

Our networking layer will be using the URL for each API call to make sure we don't overwhelm our backend. By adhering to `Hashable` we can use our existing `Request` `enum` to identify which tasks should be grouped together:

```swift
extension Request: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url.absoluteString)
    }
}
```

### 2) Keeping track of requests that have not returned:
For the actual grouping of tasks we will rely on `TaskCache`, which is a wrapper around `NSCache`. Let's inject an instance of `TaskCache` into our `Networking` instance:

```swift
struct Networking {
    
    let taskCache: TaskCache<Request, Codable>

    func fetch<Response>(_ request: Request) async throws -> Response where Response: Codable {
    	// The unthrottled networking request
    }
}
```


### 3) Throtteling requests

Let's now extend `Networking` to allow for throttling:

```swift
extension Networking {

    func throttledFetch<Response>(_ request: Request) async throws -> Response where Response: Codable {
        try await taskCache.addTask(for: request) {
            try await fetch(request) as Response
        }
    }
}
```

We can add a request to `TaskCache` by calling `addTask(for:operation:)`. The operation we pass in is the work that we want to happen just once. In this case we are calling our original wrapper for our API. Multiple calls to the same API endpoint before the original request has returned will now result in just one request being made. Once that original request has returned, all places that called the endpoint during this time will now receive the same response.


### 4) To cache or not to cache

We have control over how long each response should be valid. We can pass an optional parameter into our call to `TaskCache` that allows us to specify a throttling window, during which the original response gets cached and subsequent requests to the same endpoint will return a cached response. If `0` is passed in, the behavior is the same as discussed in the previous step.

```swift
extension Networking {

    func throttledFetch<Response>(_ request: Request, validFor seconds: TimeInterval = 0) async throws -> Response where Response: Codable {
        try await taskCache.addTask(for: request, validFor: seconds) {
            try await fetch(request) as Response
        }
    }
}
```

## Requirements

## Installation

ThrottledTask is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ThrottledTask'
```

## Author

Axel Ancona Esselmann, axel@anconaesselmann.com

## License

ThrottledTask is available under the MIT license. See the LICENSE file for more info.
