//
//  main.swift
//  SeeURL
//
//  Created by Alsey Coleman Miller on 1/26/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import XCTest

#if os(Linux)
    import Glibc
    
    XCTMain([cURLTests(), HTTPClientTests()])
#endif
