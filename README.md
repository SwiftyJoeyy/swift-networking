[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftyJoeyy%2Fswift-networking%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/SwiftyJoeyy/swift-networking)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSwiftyJoeyy%2Fswift-networking%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/SwiftyJoeyy/swift-networking)

# Swift Networking

**Swift Networking** is a modern Swift networking library built entirely around a **declarative programming model**. From defining requests to configuring clients and handling responses, everything is expressed clearly and fluentlyy.

Inspired by **Swift** & **SwiftUI**’s design philosophy, it allows you to define network behavior in a way that is readable, modular, and test-friendly — all while keeping boilerplate to a minimum.



## ✨ Highlights

- 🧾 **Fully declarative** request & response design  
- ⚙️ Custom clients, interceptors, headers, and parameters via DSL  
- 🔄 Built-in support for request/response modifiers and interceptors
- 🧪 Easy-to-test and modular architecture  
- 🧰 Modular, extensible architecture



## 📦 Installation

Add via **Swift Package Manager**:

```swift
.package(url: "https://github.com/SwiftyJoeyy/swift-networking.git", from: "1.0.0")
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
