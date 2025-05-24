//
//  JSONTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/4/25.
//

import Foundation
import Testing
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .body, .json))
struct JSONTests {
    private let url = URL(string: "example.com")!
    private let configurations = ConfigurationValues.mock
    
    @Test func setsContentTypeToApplicationJSON() throws {
        let urlRequest = URLRequest(url: url)
        let data = "Test Body".data(using: .utf8)
        let modifier = JSON(encodable: JSONEncodableMock(data: data))
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let contentType = modifiedRequest.allHTTPHeaderFields?["Content-Type"]
        #expect(contentType == BodyContentType.applicationJson.value)
    }
    
    @Test func setsHTTPBodyToEncodedData() throws {
        let urlRequest = URLRequest(url: url)
        let expectedData = "Test Body".data(using: .utf8)
        let modifier = JSON(encodable: JSONEncodableMock(data: expectedData))
        
        let modifiedRequest = try modifier.modifying(
            urlRequest,
            with: configurations
        )
        
        let data = modifiedRequest.httpBody
        #expect(data == expectedData)
    }
    
    @Test func initWithData() throws {
        let expectedData = "Test Body".data(using: .utf8)!
        let modifier = JSON(data: expectedData)
        
        let body = try modifier.body(for: configurations)
        #expect(body! == expectedData)
    }
    
    @Test func initWithCodable() throws {
        let item = DataMock()
        let modifier = JSON(item)
        
        let body = try modifier.body(for: configurations)
        let decoded = try JSONDecoder().decode(DataMock.self, from: body!)
        #expect(decoded == item)
    }
    
    @Test func initWithDictionary() throws {
        let dictionary: [String: any Sendable] = ["key": "value", "number": "42"]
        let modifier = JSON(dictionary)
        
        let data = try modifier.body(for: configurations)
        let jsonObject = try JSONSerialization.jsonObject(
            with: data!,
            options: []
        ) as? [String: String]
        
        #expect(jsonObject == dictionary as? [String: String])
    }
    
    @Test func jsonDescription() {
        let data = "Hello".data(using: .utf8)
        let encoder = JSONEncodableMock(data: data)
        let json = JSON(encodable: encoder)
        
        let result = json.description
        
        let contentType = ContentType(.applicationJson)
        #expect(result.contains("contentType = \(contentType.description)"))
        #expect(result.contains("body = JSONEncodableMock"))
    }
    
// MARK: - CodableJSONEncoder Tests
    @Test func codableJSONEncoderEncodesValidObject() throws {
        let sample = DataMock()
        let encodable = CodableJSONEncoder(sample)
        
        let data = try encodable.encoded(for: configurations)
        let decoded = try configurations.decoder.decode(DataMock.self, from: data!)
        
        #expect(decoded == sample)
    }
    
    @Test func codableJSONEncoderThrowsErrorForInvalidObject() throws {
        let sample = DataMock(test: .infinity)
        let encodable = CodableJSONEncoder(sample)
        
        try #require(throws: NetworkingError.JSONError.self) {
            _ = try encodable.encoded(for: configurations)
        }
    }
    
    @Test func codableJSONEncoderEncodesUsingCustomEncoder() throws {
        let sample = DataMock()
        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase
        let encoder = CodableJSONEncoder(sample, encoder: customEncoder)
        
        let data = try encoder.encoded(for: configurations)
        let decoder = configurations.decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(DataMock.self, from: data!)
        
        #expect(decoded == sample)
    }
    
    @Test func codableEncoderDescription() {
        let object = DataMock(test: 10)
        let encoder = CodableJSONEncoder(object)
        
        let result = encoder.description
        
        #expect(result.contains("CodableJSONEncoder = DataMock(test: \(object.test)"))
    }

// MARK: - DictionaryJSONEncoder Tests
    @Test func dictionaryJSONEncoderEncodesDictionaryCorrectly() throws {
        let dictionary: [String: String] = ["key": "value", "number": "42"]
        let encodable = DictionaryJSONEncoder(dictionary: dictionary)
        
        let data = try encodable.encoded(for: configurations)
        let jsonObject = try JSONSerialization.jsonObject(
            with: data!,
            options: []
        ) as? [String: String]
        
        #expect(jsonObject == dictionary)
    }
    
    @Test func dictionaryJSONEncoderFailsForInvalidDictionary() throws {
        let dictionary: [String: Date] = ["key": Date()]
        let encodable = DictionaryJSONEncoder(dictionary: dictionary)
        
        try #require(throws: NetworkingError.JSONError.self) {
            _ = try encodable.encoded(for: configurations)
        }
    }
    
    @Test func dictEncoderDescriptionnIsEmptyWhenDictionaryIsEmpty() {
        let encoder = DictionaryJSONEncoder(dictionary: [:])
        let result = encoder.description
        
        #expect(result == "DictionaryJSONEncoder = []")
    }
    
    @Test func dictEncoderDescriptionContainsAllKeys() {
        let encoder = DictionaryJSONEncoder(dictionary: [
            "name": "Alice",
            "email": "alice@example.com"
        ])
        let result = encoder.description
        
        #expect(result.contains("name"))
        #expect(result.contains("email"))
        #expect(result.starts(with: "DictionaryJSONEncoder"))
        #expect(result.contains("(\(encoder.dictionary.count))"))
    }
}

extension JSONTests {
    struct DataMock: Codable, Equatable {
        var test = Double.random(in: 0...100)
    }
    
    struct JSONEncodableMock: JSONEncodable {
        let data: Data?
        
        func encoded(
            for configurations: borrowing ConfigurationValues
        ) throws -> Data? {
            return data
        }
    }
}

extension Tag {
    @Tag internal static var json: Self
}
