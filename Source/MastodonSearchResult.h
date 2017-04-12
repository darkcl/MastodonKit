//
//  MastodonSearchResult.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonAccount, MastodonStatus;

@interface MastodonSearchResult : NSObject

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)infoDict;

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonAccount *> *accounts;

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonStatus *> *statuses;

@property (nonatomic, strong, readonly, nonnull) NSArray <NSString *> *hashTags;

@end
