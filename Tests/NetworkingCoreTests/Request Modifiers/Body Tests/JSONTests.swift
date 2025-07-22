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
    private let configurations = ConfigurationValues()
    
    @Test func acceptsConfigurations() throws {
        var configs = configurations
        configs.bufferSize = 1
        let encodable = JSONEncodableConfigsMock()
        let modifier = JSON(encodable: encodable)
        modifier._accept(configs)
        _ = try modifier.body()
        
        #expect(encodable.configs?.bufferSize == configs.bufferSize)
    }
    
    @Test func setsContentTypeToApplicationJSON() throws {
        let urlRequest = URLRequest(url: url)
        let data = "Test Body".data(using: .utf8)
        let modifier = JSON(encodable: JSONEncodableMock(data: data))
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let contentType = modifiedRequest.allHTTPHeaderFields?["Content-Type"]
        #expect(contentType == BodyContentType.applicationJson.value)
    }
    
    @Test func setsHTTPBodyToEncodedData() throws {
        let urlRequest = URLRequest(url: url)
        let expectedData = "Test Body".data(using: .utf8)
        let modifier = JSON(encodable: JSONEncodableMock(data: expectedData))
        
        let modifiedRequest = try modifier.modifying(urlRequest)
        
        let data = modifiedRequest.httpBody
        #expect(data == expectedData)
    }
    
    @Test func initWithData() throws {
        let expectedData = "Test Body".data(using: .utf8)!
        let modifier = JSON(data: expectedData)
        
        let body = try modifier.body()
        #expect(body! == expectedData)
    }
    
    @Test func initWithCodable() throws {
        let item = DataMock()
        let modifier = JSON(item)
        
        let body = try modifier.body()
        let decoded = try JSONDecoder().decode(DataMock.self, from: body!)
        #expect(decoded == item)
    }
    
    @Test func initWithDictionary() throws {
        let dictionary: [String: any Sendable] = ["key": "value", "number": "42"]
        let modifier = JSON(dictionary: dictionary)
        
        let data = try modifier.body()
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
    
// MARK: - FoundationJSONEncodable Tests
    @Test func foundationJSONEncodableEncodesValidObject() throws {
        let sample = DataMock()
        let encodable = FoundationJSONEncodable(sample)
        
        let data = try encodable.encoded(for: configurations)
        let decoded = try configurations.decoder.decode(DataMock.self, from: data!)
        
        #expect(decoded == sample)
    }
    
    @Test func foundationJSONEncodableThrowsErrorForInvalidObject() throws {
        let sample = DataMock(test: .infinity)
        let encodable = FoundationJSONEncodable(sample)
        
        let error = try #require(throws: NetworkingError.self) {
            _ = try encodable.encoded(for: configurations)
        }
        var foundCorrectError = false
        if case NetworkingError.encoding(.invalidValue) = error {
            foundCorrectError = true
        }
        #expect(foundCorrectError, "Found error \(String(describing: error))")
    }
    
    @Test func foundationJSONEncodableEncodesUsingCustomEncoder() throws {
        let sample = DataMock()
        let customEncoder = JSONEncoder()
        customEncoder.keyEncodingStrategy = .convertToSnakeCase
        let encoder = FoundationJSONEncodable(sample, encoder: customEncoder)
        
        let data = try encoder.encoded(for: configurations)
        let decoder = configurations.decoder
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let decoded = try decoder.decode(DataMock.self, from: data!)
        
        #expect(decoded == sample)
    }
    
    @Test func foundationJSONEncodableDescription() {
        let object = DataMock(test: 10)
        let encoder = FoundationJSONEncodable(object)
        
        let result = encoder.description
        
        #expect(result.contains("CodableJSONEncoder = DataMock(test: \(object.test)"))
    }

// MARK: - DictionaryJSONEncodable Tests
    @Test func dictionaryJSONEncodableReturnsNilForEmptyOrNilDictionary() throws {
        do {
            let encodable = DictionaryJSONEncodable(dictionary: [:])
            
            let data = try encodable.encoded(for: configurations)
            #expect(data == nil)
        }
        
        do {
            let encodable = DictionaryJSONEncodable(dictionary: nil)
            
            let data = try encodable.encoded(for: configurations)
            #expect(data == nil)
        }
    }
    
    @Test func dictionaryJSONEncodableEncodesDictionaryCorrectly() throws {
        let dictionary: [String: String] = ["key": "value", "number": "42"]
        let encodable = DictionaryJSONEncodable(dictionary: dictionary)
        
        let data = try encodable.encoded(for: configurations)
        let jsonObject = try JSONSerialization.jsonObject(
            with: data!,
            options: []
        ) as? [String: String]
        
        #expect(jsonObject == dictionary)
    }
    
    @Test func dictionaryJSONEncodableFailsForInvalidDictionary() throws {
        let dictionary: [String: Date] = ["key": Date()]
        let encodable = DictionaryJSONEncodable(dictionary: dictionary)
        

        let error = try #require(throws: NetworkingError.self) {
            _ = try encodable.encoded(for: configurations)
        }
        var foundCorrectError = false
        if case NetworkingError.serialization(.invalidObject) = error {
            foundCorrectError = true
        }
        #expect(foundCorrectError, "Found error \(String(describing: error))")
    }
    
    @Test func dictionaryJSONEncodableDescriptionIsEmptyWhenDictionaryIsEmptyOrNil() {
        do {
            let encoder = DictionaryJSONEncodable(dictionary: [:])
            let result = encoder.description
            
            #expect(result == "DictionaryJSONEncoder = []")
        }
        
        do {
            let encoder = DictionaryJSONEncodable(dictionary: nil)
            let result = encoder.description
            
            #expect(result == "DictionaryJSONEncoder = []")
        }
    }
    
    @Test func dictionaryJSONEncodableDescriptionContainsAllKeys() {
        let encoder = DictionaryJSONEncodable(dictionary: [
            "name": "Alice",
            "email": "alice@example.com"
        ])
        let result = encoder.description
        
        #expect(result.contains("name"))
        #expect(result.contains("email"))
        #expect(result.starts(with: "DictionaryJSONEncoder"))
        #expect(result.contains("(\(encoder.dictionary?.count ?? 0))"))
    }
}

// MARK: - Modifier Tests
extension JSONTests {
    @Test func appliesJSONModifierToRequest() throws {
        do {
            let encodable = DataMock()
            let request = DummyRequest()
                .json(encodable)
            
            let modifiedRequest = getModified(request, DummyRequest.self, JSON<FoundationJSONEncodable<DataMock>>.self)
            #expect(modifiedRequest?.modifier.encodable.object == encodable)
        }
        
        do {
            let object = DataMock()
            let encoder = JSONEncoder()
            let request = DummyRequest()
                .json(object, encoder: encoder)
            
            let modifiedRequest = getModified(request, DummyRequest.self, JSON<FoundationJSONEncodable<DataMock>>.self)
            let encodable = modifiedRequest?.modifier.encodable
            #expect(encodable?.object == object)
            #expect(encodable?.encoder === encoder)
        }
        
        do {
            let dictionary = ["A": "1"]
            let request = DummyRequest()
                .json(dictionary: dictionary)
            
            let modifiedRequest = getModified(request, DummyRequest.self, JSON<DictionaryJSONEncodable>.self)
            let dict = modifiedRequest?.modifier.encodable.dictionary
            let stringDict = try #require(dict as? [String: String])
            #expect(stringDict == dictionary)
        }
        
        do {
            let data = Data()
            let request = DummyRequest()
                .json(data: data)
            
            let modifiedRequest = getModified(request, DummyRequest.self, JSON<Data?>.self)
            #expect(modifiedRequest?.modifier.encodable == data)
        }
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
        ) throws(NetworkingError) -> Data? {
            return data
        }
    }
    
    class JSONEncodableConfigsMock: JSONEncodable {
        var configs: ConfigurationValues?
        
        func encoded(
            for configurations: borrowing ConfigurationValues
        ) throws(NetworkingError) -> Data? {
            configs = copy configurations
            return nil
        }
    }
}

extension Tag {
    @Tag internal static var json: Self
}
