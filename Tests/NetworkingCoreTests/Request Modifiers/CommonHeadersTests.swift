//
//  CommonHeadersTests.swift
//  Networking
//
//  Created by Joe Maghzal on 25/07/2025.
//

import Testing
import Foundation
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .headers))
struct CommonHeadersTests {
// MARK: - AcceptLanguage Tests
    @Test func acceptLanguageHeader() {
        let language = "en-US"
        let header = AcceptLanguage(language)
        #expect(header.headers == ["Accept-Language": language])
    }
    
// MARK: - ContentDisposition Tests
    @Test func contentDispositionWithRawValue() {
        let value = "inline"
        let header = ContentDisposition(value)
        #expect(header.headers == ["Content-Disposition": value])
    }
    
    @Test func contentDispositionWithNameOnly() {
        let name = "upload"
        let header = ContentDisposition(name: name)
        
        let expectedValue = #"form-data; name="\#(name)""#
        #expect(header.headers == ["Content-Disposition": expectedValue])
    }
    
    @Test func contentDispositionWithNameAndFilename() {
        let name = "upload"
        let fileName = "file.txt"
        let header = ContentDisposition(name: name, fileName: fileName)
        
        let expectedValue = #"form-data; name="\#(name)"; filename="\#(fileName)""#
        #expect(header.headers == ["Content-Disposition": expectedValue])
    }
    
// MARK: - ContentType Tests
    @Test func contentTypeWithRawValue() {
        let type = "text/plain; charset=utf-8"
        let header = ContentType(type)
        
        #expect(header.headers["Content-Type"] == type)
    }
    
    @Test(arguments: [
        (BodyContentType.applicationFormURLEncoded, "application/x-www-form-urlencoded"),
        (BodyContentType.applicationJson, "application/json"),
        (BodyContentType.multipartFormData(boundary: "abc123"), "multipart/form-data; boundary=abc123"),
        (BodyContentType.text, "text/plain"),
        (BodyContentType.html, "text/html"),
        (BodyContentType.applicationXML, "application/xml"),
        (BodyContentType.any, "*/*"),
    ])
    func contentTypeWithPreDefinedValues(type: (type: BodyContentType, value: String)) {
        let header = ContentType(type.type)
        
        #expect(header.headers["Content-Type"] == type.value)
    }
    
#if canImport(UniformTypeIdentifiers)
    @Test func contentTypeWithSupportedMimeContentType() {
        let type = UTType.plainText
        let header = ContentType(.mime(type))
        
        let value = type.preferredMIMEType
        
        #expect(header.type == value)
        #expect(header.headers["Content-Type"] == value)
    }
    
    @Test func contentTypeWithUnsupportedMimeContentType() {
        let type = UTType.text
        let header = ContentType(.mime(type))
        
        let value = "Unsupported"
        
        #expect(header.type == value)
        #expect(header.headers["Content-Type"] == value)
    }
#endif
    
// MARK: - Accept Tests
    @Test func acceptWithRawValue() {
        let type = "text/plain; charset=utf-8"
        let header = Accept(type)
        
        #expect(header.headers["Accept"] == type)
    }
    
    @Test(arguments: [
        (BodyContentType.applicationFormURLEncoded, "application/x-www-form-urlencoded"),
        (BodyContentType.applicationJson, "application/json"),
        (BodyContentType.multipartFormData(boundary: "abc123"), "multipart/form-data; boundary=abc123"),
        (BodyContentType.text, "text/plain"),
        (BodyContentType.html, "text/html"),
        (BodyContentType.applicationXML, "application/xml"),
        (BodyContentType.any, "*/*"),
    ])
    func acceptWithPreDefinedValues(type: (type: BodyContentType, value: String)) {
        let header = Accept(type.type)
        
        #expect(header.headers["Accept"] == type.value)
    }
    
#if canImport(UniformTypeIdentifiers)
    @Test func acceptWithSupportedMimeContentType() {
        let type = UTType.plainText
        let header = Accept(.mime(type))
        
        let value = type.preferredMIMEType
        
        #expect(header.type == value)
        #expect(header.headers["Accept"] == value)
    }
    
    @Test func acceptWithUnsupportedMimeContentType() {
        let type = UTType.text
        let header = Accept(.mime(type))
        
        let value = "Unsupported"
        
        #expect(header.type == value)
        #expect(header.headers["Accept"] == value)
    }
#endif
    

// MARK: - AcceptEncoding Tests
    @Test func acceptEncodingWithRawValue() {
        let value = UUID().uuidString
        let header = AcceptEncoding(value)
        
        #expect(header.headers == ["Accept-Encoding": value])
    }
    
    @Test(arguments: AcceptEncoding.EncodingType.allCases)
    func acceptEncodingWithPreDefinedValues(encoding: AcceptEncoding.EncodingType) {
        let header = AcceptEncoding(encoding)
        
        let expectedValue = encoding.rawValue
        #expect(header.headers == ["Accept-Encoding": expectedValue])
    }
    
// MARK: - UserAgent Tests
    @Test func userAgentHeader() {
        let value = UUID().uuidString
        let header = UserAgent(value)
        
        #expect(header.headers == ["User-Agent": value])
    }
    
// MARK: - Authorization Tests
    @Test func authorizationWithRawValue() {
        let auth = UUID().uuidString
        let header = Authorization(auth)
        
        #expect(header.headers == ["Authorization": auth])
    }
    
    @Test func authorizationWithBearerToken() {
        let bearer = UUID().uuidString
        let header = Authorization(bearer: bearer)
        
        let expectedValue = "Bearer \(bearer)"
        #expect(header.headers == ["Authorization": expectedValue])
    }
    
    @Test func authorizationWithBasicCredentials() throws {
        let username = UUID().uuidString
        let password = UUID().uuidString
        let header = Authorization(username: username, password: password)
        
        let encoded = try #require(
            "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        )
        let expectedValue = "Basic \(encoded)"
        
        #expect(header.headers == ["Authorization": expectedValue])
    }
    
    @Test func authorizationWithInvalidBasicCredentials() throws {
        let username = UUID().uuidString
        let password = UUID().uuidString
        let header = Authorization(username: username, password: password)
        
        let encoded = try #require(
            "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString()
        )
        let expectedValue = "Basic \(encoded)"
        
        #expect(header.headers == ["Authorization": expectedValue])
    }
}
