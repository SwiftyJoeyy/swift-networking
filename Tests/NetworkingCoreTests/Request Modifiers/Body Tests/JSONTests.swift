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
    
// MARK: - CodableJSONEncoder Tests
    @Test func codableJSONEncoderEncodesValidObject() throws {
        let sample = DataMock()
        let encodable = CodableJSONEncoder(sample)
        
        let data = try encodable.encoded(for: configurations)
        let decoded = try configurations.decoder.decode(DataMock.self, from: data!)
        
        #expect(decoded == sample)
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
}

extension JSONTests {
    struct DataMock: Codable, Equatable {
        var testName = UUID()
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
