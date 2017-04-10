//
//  MastodonClient.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonClient : NSObject <NSCoding>

+ (_Nonnull instancetype)clientWithInstanceURL:(NSURL * _Nonnull)url;

@property (nonatomic, strong, nonnull) NSURL *instanceUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *registerAppUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *authUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *tokenUrl;

#pragma mark - Resources URL

@property (nonatomic, strong, readonly, nonnull) NSURL *homeTimelineUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *publicTimelineUrl;

- (NSURL * _Nonnull)timelineWithTag:(NSString * _Nonnull)tag;

#pragma mark - OAuth

@property (readonly) BOOL isRegistered;

@property (nonatomic, strong, nullable) NSString *appId;

@property (nonatomic, strong, nullable) NSURL *redirectUri;

@property (nonatomic, strong, nullable) NSString *clientId;

@property (nonatomic, strong, nullable) NSString *clientSecret;

@end
