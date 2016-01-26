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

class cURLTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
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
        
        try! curl.setOption(CURLOPT_TIMEOUT, 5)
        
        try! curl.setOption(CURLOPT_POST, true)
        
        let data: Data = Data(byteValue: [0x54, 0x65, 0x73, 0x74]) // "Test"
        
        try! curl.setOption(CURLOPT_POSTFIELDSIZE, data.byteValue.count)
        
        let dataStorage = cURL.ReadFunctionStorage(data: data)
        
        try! curl.setOption(CURLOPT_READDATA, dataStorage)
                
        try! curl.setOption(CURLOPT_READFUNCTION, curlReadFunction)
        
        do { try curl.perform() }
        catch { print("Error executing cURL request: \(error)") }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
    }
    
    func testWriteFunction() {
        
        let curl = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        let url = "http://httpbin.org/image/jpeg"
        
        try! curl.setOption(CURLOPT_URL, url)
        
        try! curl.setOption(CURLOPT_TIMEOUT, 60)
        
        let storage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_WRITEDATA, storage)
        
        try! curl.setOption(CURLOPT_WRITEFUNCTION, cURL.WriteFunction)
        
        do { try curl.perform() }
        catch { print("Error executing cURL request: \(error)") }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        let bytes = unsafeBitCast(storage.data, [UInt8].self)
        
        let foundationData = Data(byteValue: bytes).toFoundation()
        
        XCTAssert(foundationData == NSData(contentsOfURL: NSURL(string: url)!))

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
        catch { print("Error executing cURL request: \(error)") }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        print("Header:\n\(String.fromCString(storage.data)!)")
    }
    
    func testSetHeaderOption() {
        
        var curl: cURL! = cURL()
        
        try! curl.setOption(CURLOPT_VERBOSE, true)
        
        let url = "http://httpbin.org/headers"
        
        try! curl.setOption(CURLOPT_URL, url)
        
        let header = "Header"
        
        let headerValue = "Value"
        
        try! curl.setOption(CURLOPT_HTTPHEADER, [header + ": " + headerValue])
        
        let storage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_WRITEDATA, storage)
        
        try! curl.setOption(CURLOPT_WRITEFUNCTION, curlWriteFunction)
        
        do { try curl.perform() }
        catch { print("Error executing cURL request: \(error)") }
        
        let responseCode = try! curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        XCTAssert(responseCode == 200, "\(responseCode) == 200")
        
        let bytes = unsafeBitCast(storage.data, [UInt8].self)
        
        let foundationData = Data(byteValue: bytes).toFoundation()
        
        guard let json = try! NSJSONSerialization.JSONObjectWithData(foundationData, options: NSJSONReadingOptions()) as? [String: [String: String]]
            else { XCTFail("Invalid JSON response"); return }
        
        guard let headersJSON = json["headers"]
            else { XCTFail("Invalid JSON response: \(json)"); return }
        
        XCTAssert(headersJSON[header] == headerValue)
        
        // invoke deinit
        curl = nil
    }
}
