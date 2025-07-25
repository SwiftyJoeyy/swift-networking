[![GitHub Release](https://img.shields.io/github/release/SwiftyJoeyy/swift-networking.svg?include_prereleases)](https://github.com/SwiftyJoeyy/swift-networking/releases)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftyJoeyy%2Fswift-networking%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftyJoeyy/swift-networking)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftyJoeyy%2Fswift-networking%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftyJoeyy/swift-networking)
[![License](https://img.shields.io/github/license/SwiftyJoeyy/swift-networking)](https://github.com/SwiftyJoeyy/swift-networking/blob/main/LICENSE)
[![Swift](https://github.com/SwiftyJoeyy/swift-networking/actions/workflows/swift.yml/badge.svg)](https://github.com/SwiftyJoeyy/swift-networking/actions/workflows/swift.yml)

# Swift Networking

**Swift Networking** is a modern Swift networking library built entirely around a **declarative programming model**. From defining requests to configuring clients and handling responses, everything is expressed clearly and fluentlyy.

Inspired by **Swift** & **SwiftUI**’s design philosophy, it allows you to define network behavior in a way that is readable, modular, and test-friendly — all while keeping boilerplate to a minimum.



## ✨ Highlights

- 🧾 **Fully declarative** request & response design  
- ⚙️ Custom clients, interceptors, headers, and parameters via DSL  
- 🔄 Built-in support for request/response modifiers and interceptors
- 🧪 Easy-to-test and modular architecture  
- 🧰 Modular, extensible architecture



## 🚀 Getting Started

This guide walks you through the core building blocks:
1. Defining a request.
2. Adding headers, parameters, and body.
3. Building a client.
4. Sending a request.


### 1. Defining a request
To define a request, use the [`@Request`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/request(_:)) macro. This adds conformance to the [`Request`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/request) protocol, which requires a `request` property similar to SwiftUI’s body.
Inside that property, you start with an [`HTTPRequest`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/httprequest), which represents the core of the request.

You can:

- Provide a url to override the client’s base URL
- Add an optional path
- Set the HTTP method using [`method(_:)`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/request/method(_:))
- Append extra path components using [`appending(_:)`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/request/appending(_:))
Example

```swift
@Request struct TestingRequest {
    var request: some Request {
        HTTPRequest(url: "https://www.example.com", path: "gallery")
            .method(.get)
            .appending("cats", "images")
    }
}
```
This creates a simple GET request to `https://www.google.com/test/cats/images`.

You can also compose and override requests:

```swift
@Request
struct TestRequest {
    @Header var test: String {
        return "Computed"
    }
    var request: some Request {
        TestingRequest() // TestingRequest instead of HTTPRequest
            .timeout(90)
            .method(.post)
    }
}
```


### 2. Adding Headers, Parameters, and Body

`Networking` offers multiple ways to add headers, query parameters, and request bodies. You can use macros for top level values or chaining modifiers for inline customization.

#### 🧩 Adding Parameters

Use [`Parameter`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/parameter) to create parameters from `String`, `Int`, `Double`, or `Bool` values, including arrays of those types.
You can also use [`ParametersGroup`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/parametersgroup) to group multiple parameters into one modifier.

To add parameters to a request, you use the [`@Parameter`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/parameter(_:)) macro, or dynamically through modifier methods:

```swift
@Request struct SearchRequest {
    @Parameter var query: String // Using the name of the property
    @Parameter("search_query") var query: String // Using a custom name.
    let includeFilter: Bool
    var request: some Request {
        HTTPRequest(path: "search")
            .appendingParameters {
                Parameter("query", value: "cats")
                if includeFilter {
                    Parameter("filter", value: "popular")
                }
            }.appendingParameter("sorting", value: "ascending")
            .appendingParameter("filters", values: ["new", "free"])
    }
}
```

#### 📬 Adding Headers

Use [`Header`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/header) to define headers from `String`, `Int`, `Double`, or `Bool` values.
You can also use [`HeadersGroup`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/headersgroup) if you want to group multiple headers in a single modifier, or inject a raw dictionary `[String: String]`.
You also get convenience types like: [`AcceptLanguage`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/acceptlanguage), [`ContentDisposition`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/contentdisposition) & [`ContentType`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/contenttype).
Similar to parameters, headers can also be declared statically using the [`@Header`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/header(_:)) macro or applied dynamically using modifiers:

```swift
@Request struct AuthenticatedRequest {
    @Header var token: String // Using the name of the property.
    @Header("Authorization") var token: String // Using a custom name.
    let includeLang: Bool
    var request: some Request {
        HTTPRequest(path: "me")
            .additionalHeaders {
                Header("Custom-Header", value: "value")
                if includeLang {
                    AcceptLanguage("en")
                }
            }.additionalHeader("version", value: "1.0")
    }
}
```

#### 📦 Adding a Request Body

Currently, `Networking` supports [`JSON`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/json) and [`FormData`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/formdata) request bodies.
To apply a body to a request, you can use the [`body(_:)`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/request/body(_:)) modifier, or convenience modifiers for `json`:

##### ✅ Using .body(...) Modifier

```swift
HTTPRequest(path: "upload")
    .body {
        // JSON
        JSON(["dict": "data"]) // Dictionary
        JSON(Data()) // Raw data.
        JSON(EncodableUser()) // Encodable types.

        // FormData
        FormData {
            FormDataBody( /// Raw data
                "Image",
                data: Data(),
                fileName: "image.png",
                 mimeType: .png
            )
            FormDataFile( // Data from a file.
                "File",
                fileURL: URL(filePath: "filePath"),
                fileName: "file",
                 mimeType: .fileURL
            )
        }
    }
```

##### ✅ Using JSON Convenience Modifiers
```swift
HTTPRequest(path: "create")
    .json(["name": "John", "age": 30]) // Dictionary.
    .json(Data()) // Raw data.
    .json(EncodableUser()) // Encodable types.
```
> [!CAUTION]
> If multiple `.body()` or `.json()` modifiers are used, the last one overrides the previous. This applies to all modifiers, modifier order matters.

#### 🧱 Inline Modifiers with HTTPRequest

You can also include modifiers directly in the `HTTPRequest` initializer. This gives you a clean, SwiftUI style declaration for most common request scenarios.

```swift
HTTPRequest(path: "submit") {
    Header("X-Token", value: "123")
    Parameter("query", value: "swift")
    JSON(["key": "value"])
}
```


### 3. Building a client

To define a networking client, use the [`@Client`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/client()) macro. This macro adds conformance to the [`NetworkClient`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/networkclient) protocol, which requires a `session` property. This property returns a [`Session`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/session) instance that describes how your requests should be configured and executed.

> [!IMPORTANT]
> Do not call the session property directly. It’s a computed property that creates a new session each time it’s accessed.
> Always send requests using the client instance itself (e.g. try await client.dataTask(...)).
> You should also hold on to the client instance created either using a singleton or by dependency injection to avoid creating multiple instances.

Inside the session property, you can create and customize a `Session` using a closure that returns a configured `URLSessionConfiguration`.
From there, you can apply additional behaviors such as Base URL, Logging, Retry policy, Authorization, Response validation, Encoding/decoding strategies.

```swift
@Client struct MyClient {
    var session: Session {
        Session {
            URLSessionConfiguration.default
                .urlCache(.shared)
                .requestCachePolicy(.returnCacheDataElseLoad)
                .timeoutIntervalForRequest(90)
                .timeoutIntervalForResource(90)
                .httpMaximumConnectionsPerHost(2)
                .waitForConnectivity(true)
                .headers {
                    Header("Key", value: "Value")
                }
        }
        .authorization(BearerAuthProvider())
        .baseURL("https://example.com")
        .decode(with: JSONDecoder())
        .encode(with: JSONEncoder())
        .retry(limit: 2, delay: 2)
        .enableLogs(true)
        .validate(for: [.badGateway, .created])
    }
}
```

#### ⚙️ Custom Configuration Values

You can define custom configuration keys using the [`@Config`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/config(forceunwrapped:)) macro & extending [`ConfigurationValues`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/configurationvalues):

```swift
extension ConfigurationValues {
    @Config var customConfig = CustomValue()
}
```

Then, you can set it on a task or on the session using the modifier [`configuration(_:_:)`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/configurable/configuration(_:_:)):

```swift
@Client struct MyClient {
    var session: Session {
        Session()
            .configuration(\.customConfig, CustomValue())
    }
}

let data = try await client.dataTask(TestingRequest())
    .configuration(\.customConfig, CustomValue())
    .response()
```

This allows you to define project-specific config values and inject them anywhere in your request or session pipeline.


### 4. Sending a request

To send a request, you start by creating a task from a client. The framework provides two main types of tasks:
- [`dataTask`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/session/datatask(_:)) — for requests that return data.
- [`downloadTask`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/session/downloadtask(_:)) — for file downloads.
  
Each task can be configured individually using the same modifiers available on `Session` (e.g. retry, decoding, etc.), giving you full control per request.

```swift
let task = MyClient()
    .dataTask(MyRequest())
    .retry(limit: 2)
    .validate(for: [.ok, .notModified])
```

To start a task you either call [`resume()`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/networkingtask/resume()) manually, or access the response directly (recommended) using [`response()`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/networktask/response()) or decode it to a specific type using [`decode(as:)`](https://swiftpackageindex.com/swiftyjoeyy/swift-networking/main/documentation/networking/datatask/decode(as:))

```swift
let task = MyClient().dataTask(MyRequest())

task.resume()
let result = try await task.response()
let user = try await task.decode(as: User.self)
```

> [!NOTE]
> A task will only send the request once.
> If `response()` or `decode(as:)` is called multiple times, the framework will await the result of the first call instead of resending the request.



## 📦 Installation

Add via **Swift Package Manager**:

```swift
.package(url: "https://github.com/SwiftyJoeyy/swift-networking.git", from: "1.0.0")
```

Then add `"Networking"` to your target dependencies.



## 🛣️ Planned Features

These enhancements are planned for future releases of `Networking` to further improve flexibility, control, and developer experience:

- 🪄 Simplified Request API
Quick request execution using a default client instance for lightweight use cases.

- 🔄 Resumable Downloads
Support for partial downloads and automatic resume handling across app launches or interruptions.

- 📤 Upload Task Support
Upload data or files with progress tracking, cancellation, and retry support.

- 🏷️ Request Tagging
Tag and categorize requests into logical groups for analytics, cancellation, debugging, and tracing.

- 🧪 Built-in Testing Support
Tools for mocking, stubbing, and asserting requests and responses with zero boilerplate.

- 🔄 Request Execution & Prioritization
Control request flow with custom executors, in-flight limits, and per-task priority that can escalate or drop dynamically.

- 📽 Request Recording & Playback
Capture and replay real request traffic for debugging, offline development, and test validation.



## 📖 Documentation

The [documentation](https://swiftpackageindex.com/SwiftyJoeyy/swift-networking/main/documentation/networking) is provided by [swiftpackageindex](https://swiftpackageindex.com).



## 📄 License

Licensed under the Apache 2.0 License. See the [LICENSE](https://github.com/SwiftyJoeyy/swift-networking/blob/refactored/LICENSE) file.
