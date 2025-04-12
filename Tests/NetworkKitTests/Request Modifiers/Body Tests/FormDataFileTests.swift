//
//  FormDataFileTests.swift
//  NetworkKit
//
//  Created by Joe Maghzal on 4/8/25.
//

import Foundation
import Testing
import UniformTypeIdentifiers
@testable import NetworkKit

@Suite(.tags(.requestModifiers, .body, .formData))
final class FormDataFileTests {
// MARK: - Properties
    private let fileManager = FileManager.default
    private let key = "file"
    private let fileName = "test.txt"
    private let contents: String
    private var tempDirectory: URL!
    private var tempFileURL: URL!
    
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
    
    @Test func contentSize() {
        let item = FormDataFile(key, fileURL: tempFileURL)
        
        let expectedSize = contents.data(using: .utf8)!.count
        #expect(item.contentSize == UInt64(expectedSize))
    }
    
    @Test func dataReadsCorrectly() throws {
        let item = FormDataFile("file", fileURL: tempFileURL)
        let data = try #require(try item.data())
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
        let expectedMimeType = UTType.plainText
        let expectedFileName = "testing.txt"
        let item = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: expectedFileName
        )
        let headers = item.headers.headers
        
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == expectedMimeType.preferredMIMEType)
    }
    
    @Test func headersIncludeExplicitMimeType() throws {
        let expectedMimeType = UTType.realityFile
        let expectedFileName = "testing.txt"
        let item = FormDataFile(
            key,
            fileURL: tempFileURL,
            fileName: expectedFileName,
            mimeType: expectedMimeType
        )
        let headers = item.headers.headers
        
        let contentType = try #require(headers["Content-Type"])
        #expect(contentType == expectedMimeType.preferredMIMEType)
    }
    
// MARK: - Errors Tests
    @Test func invalidURLThrowsError() {
        let invalidURL = URL(string: "https://example.com/file.txt")!
        let item = FormDataFile("file", fileURL: invalidURL)
        
        #expect(performing: {
            try item.data()
        }, throws: { error in
            let formError = error as? NKError.FormDataError
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
            try item.data()
        }, throws: { error in
            let formError = error as? NKError.FormDataError
            guard case .fileDoesNotExist(let url) = formError else {
                return false
            }
            return url == missingURL
        })
    }
    
    @Test func directoryURLThrowsError() throws {
        let item = FormDataFile("file", fileURL: tempDirectory)
        #expect(performing: {
            try item.data()
        }, throws: { error in
            let formError = error as? NKError.FormDataError
            guard case .urlIsDirectory(let url) = formError else {
                return false
            }
            return url == tempDirectory
        })
    }
}
