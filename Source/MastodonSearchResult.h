//
//  MastodonSearchResult.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@class MastodonAccount, MastodonStatus;

@interface MastodonSearchResult : MastodonObject

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonAccount *> *accounts;

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonStatus *> *statuses;

@property (nonatomic, strong, readonly, nonnull) NSArray <NSString *> *hashTags;

@end
