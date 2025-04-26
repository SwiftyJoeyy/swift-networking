//
//  FormDataTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .body, .formData))
struct FormDataTests {
    private let configurations = ConfigurationValues.mock
    
    @Test func formDataWithSingleItem() throws {
        
        let formData = FormData {
            MockFormDataItem(
                key: "username",
                content: "Test".data(using: .utf8),
                headerValues: [
                    "Content-Disposition": "form-data; name=\"username\""
                ]
            )
        }
        
        let body = try #require(try formData.body(for: configurations))
        let bodyString = try #require(String(data: body, encoding: .utf8))
        
        #expect(bodyString.contains("--network.kit.boundary."))
        #expect(bodyString.contains("Content-Disposition:form-data; name=\"username\""))
        #expect(bodyString.contains("Test"))
    }
    
    @Test func formDataWithMultipleItems() throws {
        let formData = FormData {
            MockFormDataItem(
                key: "field1",
                content: "one".data(using: .utf8),
                headerValues: ["Content-Disposition": "form-data; name=\"field1\""]
            )
            MockFormDataItem(
                key: "field2",
                content: "two".data(using: .utf8),
                headerValues: ["Content-Disposition": "form-data; name=\"field2\""]
            )
        }
        
        let body = try #require(try formData.body(for: configurations))
        let bodyString = try #require(String(data: body, encoding: .utf8))
        
        #expect(bodyString.contains("name=\"field1\""))
        #expect(bodyString.contains("name=\"field2\""))
        #expect(bodyString.contains("one"))
        #expect(bodyString.contains("two"))
    }
    
    @Test func formDataUsesCustomBoundary() throws {
        let boundary = "myCustomBoundary"
        let formData = FormData(boundary: boundary) {
            MockFormDataItem(
                key: "custom",
                content: "value".data(using: .utf8),
                headerValues: ["Content-Disposition": "form-data; name=\"custom\""]
            )
        }
        
        let body = try #require(try formData.body(for: configurations))
        let bodyString = try #require(String(data: body, encoding: .utf8))
        
        #expect(bodyString.contains("--\(boundary)"))
    }
   
    @Test func contentTypeIncludesBoundary() throws {
        let boundary = "abc123"
        let formData = FormData(boundary: boundary) {
            MockFormDataItem(
                key: "test",
                content: Data(),
                headerValues: [:]
            )
        }
        
        let type = try #require(formData.contentType)
        let contentType = type.headers["Content-Type"]
        #expect(contentType == "multipart/form-data; boundary=\(boundary)")
    }
    
    @Test func emptyFormData() throws {
        let formData = FormData { }
        
        let body = try formData.body(for: configurations)
        
        #expect(body == nil)
    }
    
    @Test func formDataWithItemWithoutData() throws {
        let formData = FormData {
            MockFormDataItem(
                key: "username",
                content: nil,
                headerValues: [
                    "Content-Disposition": "form-data; name=\"username\""
                ]
            )
        }
        
        let body = try formData.body(for: configurations)
        #expect(body == nil)
    }
}

extension FormDataTests {
    struct MockFormDataItem: FormDataItem {
        let key: String
        let content: Data?
        let headerValues: [String: String]
        
        var contentSize: UInt64? {
            return nil
        }
        var headers: HeadersGroup {
            HeadersGroup(headerValues)
        }
        func data() throws -> Data? {
            content
        }
    }
}

extension Tag {
    @Tag internal static var formData: Self
}
