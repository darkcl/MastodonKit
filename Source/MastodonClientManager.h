//
//  MastodonClientManager.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonClientManagerBuilder, MastodonClient;

typedef void(^MastodonClientManagerBuildBlock)(MastodonClientManagerBuilder * _Nonnull builder);

typedef void(^MastodonClientManagerCompletionBlock)(BOOL success, NSError * _Nullable error);

typedef void(^MastodonClientManagerLoginCompletionBlock)(BOOL success, NSURL * _Nullable authUrl, NSError * _Nullable error);

typedef void(^MastodonClientRequestComplationBlock)(BOOL success, _Nullable id response, NSError * _Nullable error);

@interface MastodonClientManager : NSObject

- (_Nonnull instancetype)initWithBlock:(_Nonnull MastodonClientManagerBuildBlock)block;

- (MastodonClient * _Nonnull)createClient:(NSURL * _Nullable)instanceUrl;

- (void)removeClient:(MastodonClient * _Nonnull)client;

#pragma mark - Login / Authenticate

- (void)registerApplicationWithClient:(MastodonClient * _Nonnull)client
                           completion:(MastodonClientManagerCompletionBlock _Nullable)completionBlock;

- (void)loginWithClient:(MastodonClient * _Nonnull)client
             completion:(MastodonClientManagerLoginCompletionBlock _Nullable)completionBlock;

#pragma mark - Fetching Data

- (void)fetchLocalTimelineWithClient:(MastodonClient * _Nonnull)client
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

@property (nonatomic, strong, nonnull) NSString *applicationName;

@property (nonatomic, strong, nonnull) NSString *redirectUri;

@property (nonatomic, strong, nonnull) NSSet <NSString *> *scopes;

@property (nonatomic, strong, nullable) NSString *websiteUrl;

@property (nonatomic, strong, nullable) NSArray <MastodonClient *> *clientsList;

@end
