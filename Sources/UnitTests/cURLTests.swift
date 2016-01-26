//
//  cURLTests.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 8/2/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX) || os(iOS)
    import cURL
#elseif os(Linux)
    import CcURL
#endif

import XCTest
import SeeURL
import SwiftFoundation

final class cURLTests: XCTestCase {
    
    lazy var allTests : [(String, () -> Void)] = [
        ("testGetStatusCode", self.testGetStatusCode),
        ("testPostField", self.testPostField),
        ("testReadFunction", self.testReadFunction),
        ("testWriteFunction", self.testWriteFunction),
        ("testHeaderWriteFunction", self.testHeaderWriteFunction),
        ("testSetHeaderOption", self.testSetHeaderOption),
    ]
    
    // MARK: - Live Tests
    
    func testGetStatusCode() {
        
        let curl = cURL()
        
        let testStatusCode = 200
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        try! curl.setOption(CURLOPT_URL, "http://httpbin.org/status/\(testStatusCode)")
        
        try! curl.setOption(CURLOPT_TIMEOUT, 5)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode: cURL.Long = try! curl.getInfo(CURLINFO_RESPONSE_CODE)
        
        XCTAssert(responseCode == testStatusCode, "\(responseCode) == \(testStatusCode)")
    }
    
    func testPostField() {
        
        let curl = cURL()
        
        let url = "http://httpbin.org/post"
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        try! curl.setOption(CURLOPT_URL, url)
        
        let effectiveURL = try! curl.getInfo(CURLINFO_EFFECTIVE_URL) as String
        
        XCTAssert(url == effectiveURL)
        
        try! curl.setOption(CURLOPT_TIMEOUT, 10)
        
        try! curl.setOption(CURLOPT_POST, true)
        
        let data: Data = Data(byteValue: [0x54, 0x65, 0x73, 0x74]) // "Test"
        
        try! curl.setOption(CURLOPT_POSTFIELDS, data)
        
        try! curl.setOption(CURLOPT_POSTFIELDSIZE, data.byteValue.count)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
    }
    
    func testReadFunction() {
        
        let curl = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        try! curl.setOption(CURLOPT_URL, "http://httpbin.org/post")
        
        try! curl.setOption(CURLOPT_TIMEOUT, 10)
        
        try! curl.setOption(CURLOPT_POST, true)
        
        let data: Data = Data(byteValue: [0x54, 0x65, 0x73, 0x74]) // "Test"
        
        try! curl.setOption(CURLOPT_POSTFIELDSIZE, data.byteValue.count)
        
        let dataStorage = cURL.ReadFunctionStorage(data: data)
        
        try! curl.setOption(CURLOPT_READDATA, dataStorage)
                
        try! curl.setOption(CURLOPT_READFUNCTION, curlReadFunction)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode = (try! curl.getInfo(CURLINFO_RESPONSE_CODE) as cURL.Long) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
    }
    
    func testWriteFunction() {
        
        let curl = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        let url = "https://httpbin.org/image/jpeg"
        
        try! curl.setOption(CURLOPT_URL, url)
        
        try! curl.setOption(CURLOPT_TIMEOUT, 60)
        
        let storage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_WRITEDATA, storage)
        
        try! curl.setOption(CURLOPT_WRITEFUNCTION, cURL.WriteFunction)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        let bytes = unsafeBitCast(storage.data, [UInt8].self)
        
        #if os(OSX) || os(iOS)
            
        let foundationData = Data(byteValue: bytes).toFoundation()
        
        XCTAssert(foundationData == NSData(contentsOfURL: NSURL(string: url)!))
        
        #endif
        
    }
    
    func testHeaderWriteFunction() {
        
        let curl = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        let url = "http://httpbin.org"
        
        try! curl.setOption(CURLOPT_URL, url)
        
        try! curl.setOption(CURLOPT_TIMEOUT, 5)
        
        let storage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_HEADERDATA, storage)
        
        try! curl.setOption(CURLOPT_HEADERFUNCTION, cURL.WriteFunction)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        print("Header:\n\(String.fromCString(storage.data)!)")
    }
    
    func testSetHeaderOption() {
        
        var curl: cURL! = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        try! curl.setOption(CURLOPT_TIMEOUT, 10)
        
        let url = "http://httpbin.org/headers"
        
        try! curl.setOption(CURLOPT_URL, url)
        
        let header = "Header"
        
        let headerValue = "Value"
        
        try! curl.setOption(CURLOPT_HTTPHEADER, [header + ": " + headerValue])
        
        let storage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_WRITEDATA, storage)
        
        try! curl.setOption(CURLOPT_WRITEFUNCTION, curlWriteFunction)
        
        do { try curl.perform() }
        catch { XCTFail("Error executing cURL request: \(error)"); return }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        guard let jsonString = String.fromCString(storage.data),
            let jsonValue = JSON.Value(string: jsonString),
            let jsonObject = jsonValue.objectValue,
            let jsonHeaders = jsonObject["headers"]?.objectValue,
            let jsonHeaderValue = jsonHeaders[header]?.rawValue as? String
            else { XCTFail("Invalid JSON response: \(String.fromCString(storage.data))"); return }
        
        XCTAssert(jsonHeaderValue == headerValue)
        
        // invoke deinit
        curl = nil
    }
}
