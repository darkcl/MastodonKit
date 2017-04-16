//
//  MastodonAccount.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@interface MastodonAccount : MastodonObject


/**
 The ID of the account
 */
@property (nonatomic, strong, readonly) NSString *accountId;


/**
 The username of the account
 */
@property (nonatomic, strong, readonly) NSString *userName;


/**
 Equals username for local users, includes @domain for remote ones
 */
@property (nonatomic, strong, readonly) NSString *acct;


/**
 The account's display name
 */
@property (nonatomic, strong, readonly) NSString *displayName;

/**
 Biography of user
 */
@property (nonatomic, strong, readonly) NSString *note;


/**
 URL of the user's profile page (can be remote)
 */
@property (nonatomic, strong, readonly) NSURL *url;


/**
 URL to the avatar image
 */
@property (nonatomic, strong, readonly) NSURL *avatar;


/**
 URL to the header image
 */
@property (nonatomic, strong, readonly) NSURL *header;


/**
 Boolean for when the account cannot be followed without waiting for approval first
 */
@property (readonly) BOOL isLocked;


/**
 The time the account was created
 */
@property (nonatomic, strong, readonly) NSDate *createAt;


/**
 The number of followers for the account
 */
@property (readonly) NSInteger followersCount;


/**
 The number of accounts the given account is following
 */
@property (readonly) NSInteger followingCount;


/**
 The number of statuses the account has made
 */
@property (readonly) NSInteger statusesCount;

@end
