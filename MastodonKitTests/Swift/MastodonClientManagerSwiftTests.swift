//
//  MastodonClientManagerSwiftTests.swift
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

import XCTest

import MastodonKit

import OHHTTPStubs

class MastodonClientManagerSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        OHHTTPStubs.removeAllStubs();
    }
    
    func testCreateWithoutAnyParam() {
        
        let sut: MastodonClientManager = MastodonClientManager.init(block: { (builder) in
            
        })
        
        XCTAssertTrue(sut.applicationName == "MastodonKit", "Application Name Should equal MastodonKit")
        
        XCTAssertTrue(sut.redirectUri == "urn:ietf:wg:oauth:2.0:oob", "Redirect Url Should equal to defualt no redirect url")
        
        let scopes: NSSet = NSSet(objects: "read", "write", "follow")
        
        let isAllScope = scopes.isEqual(to: sut.scopes)
        
        XCTAssertTrue(isAllScope, "Scope should have all permission")
    }
    
    func testCreateWithParam() {
        
        let sut: MastodonClientManager = MastodonClientManager.init(block: { (builder) in
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
    
    func testCreateClients() {
        let sut: MastodonClientManager = MastodonClientManager.init(block: { (builder) in
            
        })
        
        sut.createClient(URL(string: "https://mastodon.cloud"))
        sut.createClient(nil)
        
        XCTAssertTrue(sut.clientsList?.count == 2, "Clients count should be 2")
        XCTAssertTrue(sut.clientsList?[0].instanceUrl.absoluteString == "https://mastodon.cloud", "Clients #0 should be https://mastodon.cloud")
        XCTAssertTrue(sut.clientsList?[1].instanceUrl.absoluteString == "https://mastodon.social", "Clients #1 should be https://mastodon.social")
    }
    
    func testRegisterApp() {
        let sut: MastodonClientManager = MastodonClientManager.init(block: { (builder) in
            
        })
        
        stub(condition: isHost("mastodon.social")) { _ in
            let obj = ["id":1000,
                       "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
                       "client_id": "testing_client_id",
                       "client_secret": "testing_client_secret"] as [String : Any]
            return OHHTTPStubsResponse(jsonObject: obj, statusCode: 200, headers: nil)
        }
        
        let client = sut.createClient(nil)
        let expectation = self.expectation(description: "Testing Register App API")
        
        sut.registerApplication(with: client) { (success, error) in
            XCTAssertTrue(success, "Should Success")
            XCTAssertTrue(client.appId == "1000", "Client App Id should equal 1000")
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 5.0) { (error) in
            if (error != nil) {
                XCTFail("Expectation Failed with error: \(error)");
            }
        }
    }
}
