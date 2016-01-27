//
//  cURLError.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 8/6/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(OSX) || os(iOS)
    import cURL
#elseif os(Linux)
    import CcURL
#endif

public extension cURL {
    
    public enum Error: UInt32, ErrorType, CustomStringConvertible {
        
        case UnsupportedProtocol        = 1
        case FailedInitialization
        case BadURLFormat
        case NotBuiltIn
        case CouldNotResolveProxy
        case CouldNotResolveHost
        case CouldNotConnect
        case FTPBadServerReply
        case RemoteAccessDenied
        
        // TODO: Implement all error codes
        
        /// There was a problem reading a local file or an error returned by the read callback.
        case ReadCallback = 26
        
        case OperationTimeout = 28
        
        case BadFunctionArgument = 45
        
        public var description: String {
            
            let errorDescription = String.fromCString(curl_easy_strerror(CURLcode(rawValue: self.rawValue)))
            
            return errorDescription ?? "cURL.Error(\(self.rawValue))"
        }
    }
}