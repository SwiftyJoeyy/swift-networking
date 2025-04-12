//
//  FormDataBodyTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import UniformTypeIdentifiers
import Testing
@testable import NetworkKit

@Suite(.tags(.requestModifiers, .body, .formData))
struct FormDataBodyTests {
    
    @Test func initWithDataBody() throws {
        let key = "username"
        let content = "Test".data(using: .utf8)!
        
        let item = FormDataBody(key, data: content)
        
        #expect(item.key == key)
        #expect(try item.data() == content)
        #expect(item.contentSize == UInt64(content.count))
    }
    
    @Test func initWithStringBody() throws {
        let key = "username"
        let stringItem = FormDataBody(key, body: "Test")
        let dataItem = FormDataBody(key, data: "Test".data(using: .utf8)!)
        
        #expect(stringItem == dataItem)
    }
    
    @Test func initWithOptionalParameters() throws {
        let key = "profile"
        let content = "binarydata".data(using: .utf8)!
        let fileName = "image.png"
        let mimeType = UTType.png
        
        let item = FormDataBody(
            key,
            data: content,
            fileName: fileName,
            mimeType: mimeType
        )
        
        #expect(item.key == key)
        #expect(try item.data() == content)
        #expect(item.contentSize == UInt64(content.count))
        
        let headers = item.headers.headers
        
        let contentDisposition = try #require(headers["Content-Disposition"])
        #expect(contentDisposition.contains("name=\"\(key)\""))
        #expect(contentDisposition.contains("filename=\"\(fileName)\""))
 
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == mimeType.preferredMIMEType)
    }
    
    @Test func contentSizeIsCorrect() {
        let content = Data(repeating: 0xFF, count: 1024)
        let item = FormDataBody("data", data: content)
        #expect(item.contentSize == 1024)
    }
    
    @Test func dataReturnsOriginalBody() throws {
        let content = "Hello World".data(using: .utf8)!
        let item = FormDataBody("greeting", data: content)
        let encoded = try item.data()
        #expect(encoded == content)
    }
    
    @Test func headersWithoutFileNameOrMimeType() {
        let item = FormDataBody("simple", data: Data())
        let headers = item.headers.headers
        
        let contentDisposition = headers["Content-Disposition"]
        #expect(contentDisposition == "form-data; name=\"simple\"")
        
        let contentType = headers["Content-Type"]
        #expect(contentType == nil)
    }
}
