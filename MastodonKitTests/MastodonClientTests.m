//
//  MastodonClientTests.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <MastodonKit/MastodonKit.h>

@interface MastodonClientTests : XCTestCase {
    MastodonClient *sut;
}

@end

@implementation MastodonClientTests

- (void)testInstanceUrl {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSURL *url = [NSURL URLWithString:@"https://google.com"];
    
    sut = [MastodonClient clientWithInstanceURL:url];
    
    XCTAssertTrue([url.absoluteString isEqualToString:sut.instanceUrl.absoluteString]);
    XCTAssertTrue([sut.registerAppUrl.absoluteString isEqualToString:@"https://google.com/api/v1/apps"]);
    XCTAssertTrue([sut.authUrl.absoluteString isEqualToString:@"https://google.com/oauth/authorize?response_type=code"]);
    XCTAssertTrue([sut.tokenUrl.absoluteString isEqualToString:@"https://google.com/oauth/token"]);
}

@end
