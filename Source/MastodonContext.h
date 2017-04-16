//
//  MastodonContext.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@class MastodonStatus;

@interface MastodonContext : MastodonObject

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonStatus *> *ancestors;

@property (nonatomic, strong, readonly, nonnull) NSArray <MastodonStatus *> *descendants;

@end
