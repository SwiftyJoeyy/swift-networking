# Swift Networking

**Swift Networking** is a modern Swift networking library built entirely around a **declarative programming model**. From defining requests to configuring clients and handling responses, everything is expressed clearly and fluentlyy.

Inspired by **Swift** & **SwiftUI**’s design philosophy, it allows you to define network behavior in a way that is readable, modular, and test-friendly — all while keeping boilerplate to a minimum.



## ✨ Highlights

- 🧾 **Fully declarative** request & response design  
- ⚙️ Custom clients, interceptors, headers, and parameters via DSL  
- 🔄 Built-in support for request/response modifiers and interceptors
- 🧪 Easy-to-test and modular architecture  
- 🧰 Modular, extensible architecture



## 🚧 Upcoming Improvements

The current version of this package was released as an MVP to validate the architecture and core concepts. As such, certain areas were intentionally left unoptimized or loosely structured in favor of rapid iteration and testing. However, a major revamp is currently in progress with a strong focus on **performance**, **type safety**, and **scalability**. Here's what's planned:

- **Interceptor System Redesign**  
  The current interceptor flow is being restructured to be more **declarative** and composable, improving clarity and allowing better integration with the request lifecycle.

- **Configuration System Overhaul**  
  A new configuration model is being implemented to improve the configuration flow through **requests, modifiers, tasks, and clients**. This will make the system more robust, type-safe, and context-aware.

- **Typed Error Handling**  
  All throws across the package will become **typed**, enabling more predictable error handling, better diagnostics, and clearer call-site contracts.

- **Modifier Composition Revamp**  
  Request modifiers are being reworked for better **performance** and **composability**, eliminating unnecessary dynamic dispatch where possible and ensuring compile-time safety.

These changes are being developed incrementally and will gradually replace parts of the MVP codebase. Until then, users should expect some architectural inconsistencies and non-final APIs.



## 📦 Installation

Add via **Swift Package Manager**:

```swift
.package(url: "https://github.com/SwiftyJoeyy/swift-networking.git", branch: "refactored")
```

Then add `"Networking"` to your target dependencies.



## 🚀 Example

Here's what a full request flow looks like — from client configuration to building a reusable, composable request:

```swift
let client = MyClient()

func fetch() async throws {
    let data = try await client.dataTask(TestingRequest())
        .decode(with: JSONDecoder())
        .retryPolicy(.doNotRetry)
        .decode(as: String.self)
    
    print(data)
}
```

### 🧩 Declarative Client Configuration

```swift
@Client
struct MyClient {
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
        }.onRequest { request, task, session in
            // handle request creation
            return request
        }.enableLogs(true)
        .validate(for: [.accepted, .ok])
        .retry(limit: 2, for: [.conflict, .badRequest])
        .baseURL(URL(string: "example.com"))
        .encode(with: JSONEncoder())
        .decode(with: JSONDecoder())
    }
}
```

### ⚙️ Custom Configuration Values

You can define custom configuration keys using the `ConfigurationValues` extension:

```swift
extension ConfigurationValues {
    @Config var customConfig = CustomValue()
}
```

Then, you can set it on a task or on the session using:

```swift
@Client
struct MyClient {
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

### 🧾 Declarative Request Definitions

```swift
@Request("test-request-id")
struct TestingRequest {
    @Header("customKey") var test = "test"
    @Parameter var testing = 1

    var request: some Request {
        HTTPRequest(url: "https://www.google.com") {
            Header("test", value: "value")
            Parameter("some", values: ["1", "2"])
            JSON("value")
        }.body {
            FormData {
                FormDataBody(
                    "Image",
                    data: Data(),
                    fileName: "image.png",
                    mimeType: .png
                )
                FormDataFile(
                    "File",
                    fileURL: URL(filePath: "filePath"),
                    fileName: "file",
                    mimeType: .fileURL
                )
            }
        }.method(.get)
        .timeout(90)
        .cachePolicy(.reloadIgnoringLocalCacheData)
        .appending(path: "v1")
        .additionalHeaders {
            Header("Header", value: "10")
            AcceptLanguage("en")
        }.additionalParameters {
            Parameter("Item", value: "value")
        }
    }
}
```

### 🔁 Composing and Overriding Requests

```swift
@Request
struct TestRequest {
    @Header var test: String {
        return "Computed"
    }
    var timeout: TimeInterval = 90

    var request: some Request {
        TestingRequest()
            .timeout(timeout)
            .method(.post)
            .additionalHeaders {
                Header("Additional", value: "value")
            }.appending(paths: "v3")
    }
}
```



## 📖 Documentation

WIP: Full documentation and guides will be available soon.



## 📄 License

Licensed under the Apache 2.0 License. See the [LICENSE](https://github.com/SwiftyJoeyy/swift-networking/blob/refactored/LICENSE) file.
