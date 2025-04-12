//
//  DataLogFactoryTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/9/25.
//

import Foundation
import Testing
@testable import NetworkKit

@Suite(.tags(.utilities, .logging))
struct DataLogFactoryTests {
    @Test func nilDataReturnsEmptyData() {
        let result = DataLogFactory.make(for: nil)
        #expect(result == "Empty Data")
    }
    
    @Test func validJSONReturnsPrettyPrintedJSON() {
        let json: [String: Any] = ["name": "John", "age": 30]
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        let result = DataLogFactory.make(for: data)
        
        #expect(result.contains("\"age\" : 30"))
        #expect(result.contains("\"name\" : \"John\""))
    }
    
    @Test func utf8StringDataReturnsRawString() {
        let original = "This is a plain string"
        let data = original.data(using: .utf8)
        
        let result = DataLogFactory.make(for: data)
        
        #expect(result == original)
    }
    
    @Test func nonUTF8BinaryReturnsEmptyData() {
        let binaryData = Data([0xFF, 0x00, 0xAB, 0xCD])
        
        let result = DataLogFactory.make(for: binaryData)
        
        #expect(result == "Empty Data")
    }
    
    @Test func invalidJSONReturnsString() {
        let text = "{incomplete"
        let data = text.data(using: .utf8)!
        
        let result = DataLogFactory.make(for: data)
        
        #expect(result == text)
    }
    
    @Test func validJSONArrayReturnsPrettyPrintedArray() {
        let array = ["id": [1, 2]]
        let data = try! JSONSerialization.data(withJSONObject: array)
        
        let result = DataLogFactory.make(for: data)
        
        let expectedString = """
        {
          "id" : [
            1,
            2
          ]
        }
        """
        #expect(result == expectedString)
    }
}
