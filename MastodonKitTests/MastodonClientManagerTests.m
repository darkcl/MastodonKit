//
//  MastodonClientManagerTests.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <MastodonKit/MastodonKit.h>

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
}

- (void)testCreateWithoutAnyParam {
    MastodonClientManager *sut = [MastodonClientManager createManager:^(MastodonClientManagerBuilder * _Nonnull builder) {
        
    }];
    XCTAssertTrue([sut.applicationName isEqualToString:@"MastodonKit"], @"Application Name Should equal MastodonKit");
    XCTAssertTrue([sut.redirectUri isEqualToString:@"urn:ietf:wg:oauth:2.0:oob"], @"Redirect Url Should equal to defualt no redirect url");
    
    BOOL isScopesEqual = [sut.scopes isEqualToSet:[NSSet setWithObjects:@"read", @"write", @"follow", nil]];
    
    XCTAssertTrue(isScopesEqual, @"Scope should have all permission");
    
}

- (void)testCreateWithParam {
    MastodonClientManager *sut = [MastodonClientManager createManager:^(MastodonClientManagerBuilder * _Nonnull builder) {
        builder.applicationName = @"My Application";
        builder.scopes = [NSSet setWithObjects:@"read", nil];
        builder.redirectUri = @"myApp://oauth";
        builder.websiteUrl = @"example.com";
    }];
    XCTAssertTrue([sut.applicationName isEqualToString:@"My Application"], @"Application Name Should equal \"My Application\"");
    XCTAssertTrue([sut.redirectUri isEqualToString:@"myApp://oauth"], @"Redirect Url Should equal to myApp:\/\/oauth");
    
    BOOL isScopesEqual = [sut.scopes isEqualToSet:[NSSet setWithObjects:@"read", nil]];
    
    XCTAssertTrue(isScopesEqual, @"Scope should have read permission");
    XCTAssertTrue([sut.websiteUrl isEqualToString:@"example.com"], @"Website should equal example.com");
}

@end
