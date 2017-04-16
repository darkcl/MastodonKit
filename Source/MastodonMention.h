//
//  MastodonMention.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@interface MastodonMention : MastodonObject

/**
 URL of user's profile (can be remote)
 */
@property (nonatomic, strong, readonly) NSURL *url;

/**
 The username of the account
 */
@property (nonatomic, strong, readonly) NSString *userName;

/**
 Equals username for local users, includes @domain for remote ones
 */
@property (nonatomic, strong, readonly) NSString *acct;

/**
 Account ID
 */
@property (nonatomic, strong, readonly) NSString *accountId;

@end
