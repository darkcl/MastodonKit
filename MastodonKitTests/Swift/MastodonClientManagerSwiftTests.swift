//
//  MastodonClientManagerSwiftTests.swift
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

import XCTest

import MastodonKit

class MastodonClientManagerSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateWithoutAnyParam() {
        
        let sut: MastodonClientManager = MastodonClientManager.createManager({ (builder) in
            
        })
        
        XCTAssertTrue(sut.applicationName == "MastodonKit", "Application Name Should equal MastodonKit")
        
        XCTAssertTrue(sut.redirectUri == "urn:ietf:wg:oauth:2.0:oob", "Redirect Url Should equal to defualt no redirect url")
        
        let scopes: NSSet = NSSet(objects: "read", "write", "follow")
        
        let isAllScope = scopes.isEqual(to: sut.scopes)
        
        XCTAssertTrue(isAllScope, "Scope should have all permission")
    }
    
    func testCreateWithParam() {
        
        let sut: MastodonClientManager = MastodonClientManager.createManager({ (builder) in
            builder.applicationName = "My Application";
            builder.scopes = ["read"];
            builder.redirectUri = "myApp://oauth";
            builder.websiteUrl = "example.com";
        })
        
        XCTAssertTrue(sut.applicationName == "My Application", "Application Name Should equal My Application")
        
        XCTAssertTrue(sut.redirectUri == "myApp://oauth", "Redirect Url Should equal to myApp://oauth")
        
        let scopes: NSSet = NSSet(objects: "read")
        
        let isScopesEqual = scopes.isEqual(to: sut.scopes)
        
        XCTAssertTrue(isScopesEqual, "Scope should have all permission")
        XCTAssertTrue(sut.websiteUrl == "example.com", "Website should equal example.com");
    }
    
}
