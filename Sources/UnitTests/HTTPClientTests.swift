//
//  HTTPClientTests.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 8/9/15.
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

final class HTTPClientTests: XCTestCase {
    
    lazy var allTests : [(String, () -> Void)] = [
            ("testStatusCode", self.testStatusCode)
        ]

    func testStatusCode() {
        
        let originalStatusCode = HTTP.StatusCode.OK
        
        var url = SwiftFoundation.URL(scheme: "https")
        
        url.host = "httpbin.org"
        
        url.path = "status/\(originalStatusCode.rawValue)"
        
        let request = SwiftFoundation.HTTP.Request(URL: url.URLString!)
        
        let client = SeeURL.HTTPClient()
        
        var response: HTTP.Response!
        
        do { response = try client.sendRequest(request) }
        catch { XCTFail("\(error)"); return }
        
        let statusCode = response.statusCode
        
        XCTAssert(statusCode == originalStatusCode.rawValue, "\(statusCode) == \(originalStatusCode.rawValue)")
    }
}
