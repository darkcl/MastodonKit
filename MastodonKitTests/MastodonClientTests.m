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

- (void)testClientUrl {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    
    sut = [MastodonClient clientWithInstanceURL:url];
    
    XCTAssertTrue([url.absoluteString isEqualToString:sut.instanceUrl.absoluteString]);
    XCTAssertTrue([sut.registerAppUrl.absoluteString isEqualToString:@"https://example.com/api/v1/apps"]);
    XCTAssertTrue([sut.authUrl.absoluteString isEqualToString:@"https://example.com/oauth/authorize?response_type=code"]);
    XCTAssertTrue([sut.tokenUrl.absoluteString isEqualToString:@"https://example.com/oauth/token"]);
    
    XCTAssertTrue([[sut timelineWithTag:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/tag/test"]);
    XCTAssertTrue([[sut homeTimelineUrl].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/home"]);
    XCTAssertTrue([[sut publicTimelineUrl].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/public"]);
    XCTAssertTrue([[sut currentUserUrl].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/verify_credentials"]);
    XCTAssertTrue([[sut accountUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test"]);
    XCTAssertTrue([[sut accountFollowersUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/followers"]);
    XCTAssertTrue([[sut accountFollowingsUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/following"]);
    XCTAssertTrue([[sut accountStatusesUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/statuses"]);
}

@end
