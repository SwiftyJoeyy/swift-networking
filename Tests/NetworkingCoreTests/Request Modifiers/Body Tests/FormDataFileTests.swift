//
//  FormDataFileTests.swift
//  Networking
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
@testable import NetworkingCore

@Suite(.tags(.requestModifiers, .body, .formData))
final class FormDataFileTests {
// MARK: - Properties
    private let fileManager = FileManager.default
    private let key = "file"
    private let fileName = "test.txt"
    private let contents: String
    private var tempDirectory: URL!
    private var tempFileURL: URL!
    private let configs = ConfigurationValues.mock
    
// MARK: - Lifecycle
    init() throws {
        self.contents = "Hello, world!"
        tempDirectory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        tempFileURL = tempDirectory.appendingPathComponent(fileName)
        try contents.data(using: .utf8)?.write(to: tempFileURL)
    }
    deinit {
        try? fileManager.removeItem(at: tempDirectory)
    }
    
// MARK: - Tests
    @Test func initWithFilePath() {
        let filePathItem = FormDataFile(key, filePath: tempFileURL.absoluteString)
        let urlItem = FormDataFile(key, fileURL: tempFileURL)
        
        #expect(filePathItem == urlItem)
    }
    
    @Test func dataReadsCorrectly() throws {
        let item = FormDataFile("file", fileURL: tempFileURL)
        let data = try #require(try item.data(configs))
        let string = String(data: data, encoding: .utf8)
        
        #expect(string == contents)
    }
    
// MARK: - File Name Tests
    @Test func headersIncludeImplicitFilename() throws {
        let item = FormDataFile(
            key,
            fileURL: tempFileURL
        )
        let headers = item.headers.headers
        
        let contentDisposition = try #require(headers["Content-Disposition"])
        #expect(contentDisposition.contains("name=\"\(key)\""))
        #expect(contentDisposition.contains("filename=\"\(fileName)\""))
    }
    
    @Test func headersIncludeExplicitFilename() throws {
        let expectedFileName = "testing.txt"
        let item = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: expectedFileName
        )
        let headers = item.headers.headers
        
        let contentDisposition = try #require(headers["Content-Disposition"])
        #expect(contentDisposition.contains("name=\"\(key)\""))
        #expect(contentDisposition.contains("filename=\"\(expectedFileName)\""))
    }
    
// MARK: - Mime Type Tests
    @Test func headersIncludeImplicitMimeType() throws {
        let expectedMimeType = "text/plain"
        let expectedFileName = "testing.txt"
        let item = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: expectedFileName
        )
        let headers = item.headers.headers
        
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == expectedMimeType)
    }
    
    @Test func headersIncludeExplicitMimeType() throws {
#if canImport(UniformTypeIdentifiers)
        let expectedMimeType = UTType.plainText
#else
        let expectedMimeType = "text/plain"
#endif
        let expectedFileName = "testing.txt"
        let item = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: expectedFileName,
            mimeType: expectedMimeType
        )
        let headers = item.headers.headers
        
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == "text/plain")
    }
    
// MARK: - Errors Tests
    @Test func invalidURLThrowsError() {
        let invalidURL = URL(string: "https://example.com/file.txt")!
        let item = FormDataFile("file", fileURL: invalidURL)
        
        #expect(performing: {
            try item.data(configs)
        }, throws: { error in
            let formError = error as? NetworkingError.FormDataError
            guard case .invalidFileURL(let url) = formError else {
                return false
            }
            return url == invalidURL
        })
    }
    
    @Test func missingFileThrowsError() {
        let missingURL = tempDirectory.appendingPathComponent("missing.txt")
        let item = FormDataFile("file", fileURL: missingURL)
        
        #expect(performing: {
            try item.data(configs)
        }, throws: { error in
            let formError = error as? NetworkingError.FormDataError
            guard case .fileDoesNotExist(let url) = formError else {
                return false
            }
            return url == missingURL
        })
    }
    
    @Test func directoryURLThrowsError() throws {
        let item = FormDataFile("file", fileURL: tempDirectory)
        #expect(performing: {
            try item.data(configs)
        }, throws: { error in
            let formError = error as? NetworkingError.FormDataError
            guard case .urlIsDirectory(let url) = formError else {
                return false
            }
            return url == tempDirectory
        })
    }
    
// MARK: - Description Tests
    @Test func descriptionIncludesAllFields() {
        let key = "profileImage"
#if canImport(UniformTypeIdentifiers)
        let mimeType = UTType.png
#else
        let mimeType = "png"
#endif
        let file = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: fileName,
            mimeType: mimeType
        )
        
        let result = file.description
        
#if canImport(UniformTypeIdentifiers)
        let contentType = ContentType(.mime(mimeType))
#else
        let contentType = ContentType(.custom(mimeType))
#endif
        
        #expect(result.contains("key = \(key)"))
        #expect(result.contains("fileName = \(fileName)"))
        #expect(result.contains("fileURL = \(tempFileURL!)"))
        #expect(result.contains("mimeType = \(mimeType.description)"))
        #expect(result.contains(contentType.type.value))
    }
}
