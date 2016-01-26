//
//  HTTPClient.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 7/20/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX) || os(iOS)
    import cURL
#elseif os(Linux)
    import CcURL
#endif

import SwiftFoundation

/// Loads HTTP requests
public struct HTTPClient: URLClient {
    
    public init() { }
    
    public var verbose = false
    
    public func sendRequest(request: HTTP.Request) throws -> HTTP.Response {
        
        // Only HTTP 1.1 is supported
        guard request.version == HTTP.Version(1, 1) else { throw Error.BadRequest }
        
        let url = request.URL
        
        let curl = cURL()
        
        try curl.setOption(CURLOPT_VERBOSE, self.verbose)
        
        try curl.setOption(CURLOPT_URL, url)
        
        try curl.setOption(CURLOPT_TIMEOUT, cURL.Long(request.timeoutInterval))
        
        // append data
        if let bodyData = request.body {
            
            try curl.setOption(CURLOPT_POSTFIELDS, bodyData)
            
            try curl.setOption(CURLOPT_POSTFIELDSIZE, bodyData.byteValue.count)
        }
        
        // set HTTP method
        switch request.method {
            
        case .HEAD:
            try curl.setOption(CURLOPT_NOBODY, true)
            try curl.setOption(CURLOPT_CUSTOMREQUEST, request.method.rawValue)
            
        case .POST:
            try curl.setOption(CURLOPT_POST, true)
            
        case .GET: try curl.setOption(CURLOPT_HTTPGET, true)
            
        default:
            
            try curl.setOption(CURLOPT_CUSTOMREQUEST, request.method.rawValue)
        }
        
        // set headers
        if request.headers.count > 0 {
            
            var curlHeaders = [String]()
            
            for (header, headerValue) in request.headers {
                
                curlHeaders.append(header + ": " + headerValue)
            }
            
            try curl.setOption(CURLOPT_HTTPHEADER, curlHeaders)
        }
        
        // set response data callback
        
        let responseBodyStorage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_WRITEDATA, responseBodyStorage)
        
        try! curl.setOption(CURLOPT_WRITEFUNCTION, curlWriteFunction)
        
        let responseHeaderStorage = cURL.WriteFunctionStorage()
        
        try! curl.setOption(CURLOPT_HEADERDATA, responseHeaderStorage)
        
        try! curl.setOption(CURLOPT_HEADERFUNCTION, curlWriteFunction)
        
        // connect to server
        try curl.perform()
        
        let responseCode = try curl.getInfo(CURLINFO_RESPONSE_CODE) as Int
        
        var response = HTTP.Response()
        
        response.statusCode = responseCode
        
        // TODO: implement header parsing
        
        response.body = unsafeBitCast(responseBodyStorage.data, Data.self)
        
        return response
    }
    
    public enum Error: ErrorType {
        
        /// The provided request was malformed.
        case BadRequest
    }
}

// MARK: - Linux Support

#if os(Linux)
    public extension SwiftFoundation.HTTP {
        public typealias Client = SeeURL.HTTPClient
    }
    
    public let CURLOPT_WRITEDATA = CURLOPT_FILE
    public let CURLOPT_HEADERDATA = CURLOPT_WRITEHEADER
    public let CURLOPT_READDATA = CURLOPT_INFILE
    public let CURLOPT_RTSPHEADER = CURLOPT_HTTPHEADER
    
#endif

