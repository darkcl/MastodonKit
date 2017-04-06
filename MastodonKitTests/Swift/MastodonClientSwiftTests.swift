//
//  MastodonClientSwiftTests.swift
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

import XCTest

import MastodonKit

class MastodonClientSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInstanceUrl() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        if let url = URL(string: "http://google.com") {
            let sut = MastodonClient.init(instanceURL: url)
            
            XCTAssertTrue(url.absoluteString == sut.instanceUrl.absoluteString, "URL Should Equal")
            
        }else{
            XCTFail("URL Should not nil.")
        }
    }
}