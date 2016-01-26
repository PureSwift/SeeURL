//
//  cURLError.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 8/6/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

#if os(Linux)
    import CcURL
#endif

public extension cURL {
    
    public enum Error: UInt32, ErrorType {
        
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
        
        case OperationTimeout = 28
        
        case BadFunctionArgument = 45
    }
}