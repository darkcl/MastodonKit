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
    MastodonClientManager *sut = [MastodonClientManager createManagerWithBuilder:^(MastodonClientManagerBuilder * _Nonnull builder) {
        
    }];
    XCTAssertTrue([sut.applicationName isEqualToString:@"MastodonKit"], @"Application Name Should equal MastodonKit");
    XCTAssertTrue([sut.redirectUri isEqualToString:@"urn:ietf:wg:oauth:2.0:oob"], @"Redirect Url Should equal to defualt no redirect url");
    
    BOOL isAllScopes = [sut.scopes isEqualToSet:[NSSet setWithObjects:@"read", @"write", @"follow", nil]];
    
    XCTAssertTrue(isAllScopes, @"Scope should have all permission");
    
}

@end
