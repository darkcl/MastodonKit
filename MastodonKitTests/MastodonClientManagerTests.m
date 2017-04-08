//
//  MastodonClientManagerTests.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <MastodonKit/MastodonKit.h>

#import <OHHTTPStubs/OHHTTPStubs.h>
#import <OHHTTPStubs/OHHTTPStubsResponse+JSON.h>

@interface MastodonClientManagerTests : XCTestCase {
    
}

@end

@implementation MastodonClientManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [OHHTTPStubs removeAllStubs];
}

- (void)testCreateWithoutAnyParam {
    MastodonClientManager *sut = [[MastodonClientManager alloc] initWithBlock:^(MastodonClientManagerBuilder * _Nonnull builder) {
        
    }];
    XCTAssertTrue([sut.applicationName isEqualToString:@"MastodonKit"], @"Application Name Should equal MastodonKit");
    XCTAssertTrue([sut.redirectUri isEqualToString:@"urn:ietf:wg:oauth:2.0:oob"], @"Redirect Url Should equal to defualt no redirect url");
    
    BOOL isScopesEqual = [sut.scopes isEqualToSet:[NSSet setWithObjects:@"read", @"write", @"follow", nil]];
    
    XCTAssertTrue(isScopesEqual, @"Scope should have all permission");
    
}

- (void)testCreateWithParam {
    MastodonClientManager *sut = [[MastodonClientManager alloc] initWithBlock:^(MastodonClientManagerBuilder * _Nonnull builder) {
        builder.applicationName = @"My Application";
        builder.scopes = [NSSet setWithObjects:@"read", nil];
        builder.redirectUri = @"myApp://oauth";
        builder.websiteUrl = @"example.com";
    }];
    XCTAssertTrue([sut.applicationName isEqualToString:@"My Application"], @"Application Name Should equal \"My Application\"");
    XCTAssertTrue([sut.redirectUri isEqualToString:@"myApp://oauth"], @"Redirect Url Should equal to myApp://oauth");
    
    BOOL isScopesEqual = [sut.scopes isEqualToSet:[NSSet setWithObjects:@"read", nil]];
    
    XCTAssertTrue(isScopesEqual, @"Scope should have read permission");
    XCTAssertTrue([sut.websiteUrl isEqualToString:@"example.com"], @"Website should equal example.com");
}

- (void)testCreateClients {
    MastodonClientManager *sut = [[MastodonClientManager alloc] initWithBlock:^(MastodonClientManagerBuilder * _Nonnull builder) {
        
    }];
    
    [sut createClient:[NSURL URLWithString:@"https://mastodon.cloud"]];
    [sut createClient:nil];
    
    XCTAssertTrue(sut.clientsList.count == 2, @"Clients count should be 2");
    
    XCTAssertTrue([sut.clientsList[0].instanceUrl.absoluteString isEqualToString:@"https://mastodon.cloud"], @"Clients #0 should be https://mastodon.cloud");
    XCTAssertTrue([sut.clientsList[1].instanceUrl.absoluteString isEqualToString:@"https://mastodon.social"], @"Clients #1 should be https://mastodon.social");
}

- (void)testRegisterApp {
    MastodonClientManager *sut = [[MastodonClientManager alloc] initWithBlock:^(MastodonClientManagerBuilder * _Nonnull builder) {
        
    }];
    MastodonClient *client = [sut createClient:nil];
    
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL.host isEqualToString:@"mastodon.social"];
    } withStubResponse:^OHHTTPStubsResponse*(NSURLRequest *request) {
        NSDictionary* obj = @{@"id": @1000,
                              @"redirect_uri": @"urn:ietf:wg:oauth:2.0:oob",
                              @"client_id": @"testing_client_id",
                              @"client_secret": @"testing_client_secret"};
        return [OHHTTPStubsResponse responseWithJSONObject:obj statusCode:200 headers:nil];
    }];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Testing Register App API"];
    
    [sut registerApplicationWithClient:client
                            completion:^(BOOL success, NSError * _Nullable error) {
                                XCTAssertTrue(success, @"Should Success");
                                XCTAssertTrue([client.appId isEqualToString:@"1000"], @"Client App Id should equal 1000");
                                [expectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        
        if(error)
        {
            XCTFail(@"Expectation Failed with error: %@", error);
        }
        
    }];
}

@end
