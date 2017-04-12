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

- (void)setUp{
    [super setUp];
    
    NSURL *url = [NSURL URLWithString:@"https://example.com"];
    
    sut = [MastodonClient clientWithInstanceURL:url];
}

- (void)tearDown{
    [super tearDown];
    
}

- (void)testClientInstanceUrl {
    XCTAssertTrue([sut.instanceUrl.absoluteString isEqualToString:@"https://example.com"]);
}

- (void)testClientRegisterAppUrl {
    XCTAssertTrue([sut.registerAppUrl.absoluteString isEqualToString:@"https://example.com/api/v1/apps"]);
}

- (void)testOAuthRelatedUrl{
    XCTAssertTrue([sut.authUrl.absoluteString isEqualToString:@"https://example.com/oauth/authorize?response_type=code"]);
    XCTAssertTrue([sut.tokenUrl.absoluteString isEqualToString:@"https://example.com/oauth/token"]);
}

- (void)testTimelineRelatedUrl{
    XCTAssertTrue([[sut timelineWithTag:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/tag/test"]);
    XCTAssertTrue([[sut homeTimelineUrl].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/home"]);
    XCTAssertTrue([[sut publicTimelineUrl].absoluteString isEqualToString:@"https://example.com/api/v1/timelines/public"]);
}

- (void)testAccountRelatedUrl{
    XCTAssertTrue([[sut currentUserUrl].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/verify_credentials"]);
    XCTAssertTrue([[sut accountUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test"]);
    XCTAssertTrue([[sut accountFollowersUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/followers"]);
    XCTAssertTrue([[sut accountFollowingsUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/following"]);
    XCTAssertTrue([[sut accountStatusesUrlWithAccountId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/statuses"]);
    
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeFollow].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/follow"]);
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeUnfollow].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/unfollow"]);
    
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeBlock].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/block"]);
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeUnblock].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/unblock"]);
    
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeMute].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/mute"]);
    
    XCTAssertTrue([[sut accountOperationUrlWithAccountId:@"test" operationType:MastodonClientAccountOperationTypeUnmute].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/test/unmute"]);
    
    NSArray *testIds = @[@"test1", @"test2"];
    
    XCTAssertTrue([[sut accountRelationshipUrlWithAccountIds:testIds].absoluteString isEqualToString:@"https://example.com/api/v1/accounts/relationships?id%5B%5D=test1&id%5B%5D=test2"]);
    
    XCTAssertTrue([sut.blockedAccountUrl.absoluteString isEqualToString:@"https://example.com/api/v1/blocks"]);
    XCTAssertTrue([sut.favouriteStatusesUrl.absoluteString isEqualToString:@"https://example.com/api/v1/favourites"]);
    
    XCTAssertTrue([sut.followRequestsUrl.absoluteString isEqualToString:@"https://example.com/api/v1/follow_requests"]);
    
    XCTAssertTrue([sut.apporveFollowRequestsUrl.absoluteString isEqualToString:@"https://example.com/api/v1/follow_requests/authorize"]);
    
    XCTAssertTrue([sut.rejectFollowRequestsUrl.absoluteString isEqualToString:@"https://example.com/api/v1/follow_requests/reject"]);
    
    XCTAssertTrue([sut.followsAccountUrl.absoluteString isEqualToString:@"https://example.com/api/v1/follows"]);
    
    XCTAssertTrue([sut.muteAccountUrl.absoluteString isEqualToString:@"https://example.com/api/v1/mutes"]);
    
    XCTAssertTrue([sut.mediaAttachmentUrl.absoluteString isEqualToString:@"https://example.com/api/v1/media"]);
}

- (void)testNotificationRelatedUrl{
    XCTAssertTrue([sut.notificationUrl.absoluteString isEqualToString:@"https://example.com/api/v1/notifications"]);
    XCTAssertTrue([[sut notificationUrlWithNotificationId:@"test"].absoluteString isEqualToString:@"https://example.com/api/v1/notifications/test"]);
    XCTAssertTrue([sut.clearNotificationUrl.absoluteString isEqualToString:@"https://example.com/api/v1/notifications/clear"]);
}

- (void)testReportUrl{
    XCTAssertTrue([sut.reportUrl.absoluteString isEqualToString:@"https://example.com/api/v1/reports"]);
}

@end
