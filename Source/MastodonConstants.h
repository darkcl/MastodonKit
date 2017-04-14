//
//  MastodonConstants.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const MastodonAPIVersion;

FOUNDATION_EXPORT NSString * const MastodonKitClientsKey;

FOUNDATION_EXPORT NSString * const MastodonKitErrorDomain;

FOUNDATION_EXPORT NSString * const MastodonKitLastUsedClientKey;

FOUNDATION_EXPORT NSString * const MastodonKitApplicationName;

FOUNDATION_EXPORT NSString * const MastodonKitRedirectUri;

FOUNDATION_EXPORT NSString * const MastodonKitWebsitUrl;

/**
 Status Visibility Type
 
 - MastodonStatusVisibilityUnknow: Unknown Type
 - MastodonStatusVisibilityPublic: Public status
 - MastodonStatusVisibilityUnlisted: Unlisted status
 - MastodonStatusVisibilityPrivate: Private status
 - MastodonStatusVisibilityDirect: Direct status
 */
typedef NS_ENUM(NSInteger, MastodonStatusVisibility) {
    MastodonStatusVisibilityUnknow = -1,
    MastodonStatusVisibilityPublic,
    MastodonStatusVisibilityUnlisted,
    MastodonStatusVisibilityPrivate,
    MastodonStatusVisibilityDirect
};
