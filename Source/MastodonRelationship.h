//
//  MastodonRelationship.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 11/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonRelationship : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)infoDict;


/**
 Whether the user is currently following the account
 */
@property (readonly) BOOL isFollowing;

/**
 Whether the user is currently being followed by the account
 */
@property (readonly) BOOL isFollowedBy;

/**
 Whether the user is currently blocking the account
 */
@property (readonly) BOOL isBlocking;

/**
 Whether the user is currently muting the account
 */
@property (readonly) BOOL isMuting;

/**
 Whether the user has requested to follow the account
 */
@property (readonly) BOOL isRequested;

@property (nonatomic, strong, readonly) NSString *accountId;

@end
