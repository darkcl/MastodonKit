//
//  MastodonStatus.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonAccount, MastodonAttachment, MastodonMention, MastodonTags, MastodonApplication;


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

@interface MastodonStatus : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)infoDict;

/**
 The ID of the status
 */
@property (nonatomic, strong, readonly) NSString *statusId;


/**
 A Fediverse-unique resource ID
 */
@property (nonatomic, strong, readonly) NSString *uri;


/**
 URL to the status page (can be remote)
 */
@property (nonatomic, strong, readonly) NSURL *url;


/**
 The Account (MastodonAccount) which posted the status
 */
@property (nonatomic, strong, readonly) MastodonAccount *account;


/**
 null or the ID of the status it replies to
 */
@property (nonatomic, strong, readonly) NSString *inReplyToId;


/**
 null or the ID of the account it replies to
 */
@property (nonatomic, strong, readonly) NSString *inReplyToAccountId;

/**
 null or the reblogged Status (MastodonStatus)
 */
@property (nonatomic, strong, readonly) MastodonStatus *reblog;


/**
 Body of the status; this will contain HTML (remote HTML already sanitized)
 */
@property (nonatomic, strong, readonly) NSString *content;


/**
 The time the status was created (Convert to local time)
 */
@property (nonatomic, strong, readonly) NSDate *createAt;


/**
 The number of reblogs for the status
 */
@property (readonly) NSInteger reblogsCount;


/**
 The number of favourites for the status
 */
@property (readonly) NSInteger favouritesCount;


/**
 Whether the authenticated user has reblogged the status
 */
@property (readonly) BOOL reblogged;


/**
 Whether the authenticated user has favourited the status
 */
@property (readonly) BOOL favourited;


/**
 Whether media attachments should be hidden by default
 */
@property (readonly) BOOL sensitive;


/**
 If not empty, warning text that should be displayed before the actual content
 */
@property (nonatomic, strong, readonly) NSString *spoilerText;


/**
 One of: public, unlisted, private, direct
 */
@property (readonly) MastodonStatusVisibility visibility;


/**
 An array of Attachments (MastodonAttachment)
 */
@property (nonatomic, strong, readonly) NSArray <MastodonAttachment *> *mediaAttachments;


/**
 An array of Mentions (MastodonMention)
 */
@property (nonatomic, strong, readonly) NSArray <MastodonMention *> *mentions;


/**
 An array of Tags (MastodonTags)
 */
@property (nonatomic, strong, readonly) NSArray <MastodonTags *> *tags;

/**
 Application (MastodonApplication) from which the status was posted
 */
@property (nonatomic, strong, readonly) MastodonApplication *application;

@end
