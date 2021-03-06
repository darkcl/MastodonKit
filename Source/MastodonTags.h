//
//  MastodonTags.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@interface MastodonTags : MastodonObject

/**
 The hashtag, not including the preceding #
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 The URL of the hashtag
 */
@property (nonatomic, strong, readonly) NSURL *url;

@end
