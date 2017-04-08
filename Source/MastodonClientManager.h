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

@interface MastodonClientManager : NSObject

- (_Nonnull instancetype)initWithBlock:(_Nonnull MastodonClientManagerBuildBlock)block;

- (MastodonClient * _Nonnull)createClient:(NSURL * _Nullable)instanceUrl;

@property (nonatomic, strong, nonnull) NSString *applicationName;

@property (nonatomic, strong, nonnull) NSString *redirectUri;

@property (nonatomic, strong, nonnull) NSSet <NSString *> *scopes;

@property (nonatomic, strong, nullable) NSString *websiteUrl;

@property (nonatomic, strong, nullable) NSArray <MastodonClient *> *clientsList;

@end
