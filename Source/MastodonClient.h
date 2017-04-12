//
//  MastodonClient.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MastodonClientAccountOperationType) {
    MastodonClientAccountOperationTypeFollow,
    MastodonClientAccountOperationTypeUnfollow,
    MastodonClientAccountOperationTypeBlock,
    MastodonClientAccountOperationTypeUnblock,
    MastodonClientAccountOperationTypeMute,
    MastodonClientAccountOperationTypeUnmute
};

typedef NS_ENUM(NSInteger, MastodonClientStatusOperationType) {
    MastodonClientStatusOperationTypeReblog,
    MastodonClientStatusOperationTypeUnreblog,
    MastodonClientStatusOperationTypeFavourite,
    MastodonClientStatusOperationTypeUnfavourite
};

@interface MastodonClient : NSObject <NSCoding>

+ (_Nonnull instancetype)clientWithInstanceURL:(NSURL * _Nonnull)url;

@property (nonatomic, strong, nonnull) NSURL *instanceUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *registerAppUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *authUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *tokenUrl;

#pragma mark - Timeline Resources URL

@property (nonatomic, strong, readonly, nonnull) NSURL *homeTimelineUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *publicTimelineUrl;

- (NSURL * _Nonnull)timelineWithTag:(NSString * _Nonnull)tag;

#pragma mark - Account Resources URL

@property (nonatomic, strong, readonly, nonnull) NSURL *currentUserUrl;

- (NSURL * _Nonnull)accountUrlWithAccountId:(NSString * _Nonnull)accountId;

- (NSURL * _Nonnull)accountFollowersUrlWithAccountId:(NSString * _Nonnull)accountId;

- (NSURL * _Nonnull)accountFollowingsUrlWithAccountId:(NSString * _Nonnull)accountId;

- (NSURL * _Nonnull)accountStatusesUrlWithAccountId:(NSString * _Nonnull)accountId;

- (NSURL * _Nonnull)accountOperationUrlWithAccountId:(NSString * _Nonnull)accountId operationType:(MastodonClientAccountOperationType)type;

- (NSURL * _Nonnull)accountRelationshipUrlWithAccountIds:(NSArray <NSString *> * _Nonnull)accountIds;

@property (nonatomic, strong, readonly, nonnull) NSURL *blockedAccountUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *muteAccountUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *favouriteStatusesUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *followRequestsUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *apporveFollowRequestsUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *rejectFollowRequestsUrl;

@property (nonatomic, strong, readonly, nonnull) NSURL *followsAccountUrl;

#pragma mark - Media URL

@property (nonatomic, strong, readonly, nonnull) NSURL *mediaAttachmentUrl;

#pragma mark - Notification URL

@property (nonatomic, strong, readonly, nonnull) NSURL *notificationUrl;

- (NSURL * _Nonnull)notificationUrlWithNotificationId:(NSString * _Nonnull)notificationId;

@property (nonatomic, strong, readonly, nonnull) NSURL *clearNotificationUrl;

#pragma mark - Report URL

@property (nonatomic, strong, readonly, nonnull) NSURL *reportUrl;

#pragma mark - Search URL

@property (nonatomic, strong, readonly, nonnull) NSURL *searchUrl;

#pragma mark - Statuses Related URL

@property (nonatomic, strong, readonly, nonnull) NSURL *statusUrl;

- (NSURL * _Nonnull)statusUrlWithStatusId:(NSString * _Nonnull)statusId;

- (NSURL * _Nonnull)statusContextUrlWithStatusId:(NSString * _Nonnull)statusId;

- (NSURL * _Nonnull)statusCardUrlWithStatusId:(NSString * _Nonnull)statusId;

- (NSURL * _Nonnull)statusReblogUrlWithStatusId:(NSString * _Nonnull)statusId;

- (NSURL * _Nonnull)statusFavouriteUrlWithStatusId:(NSString * _Nonnull)statusId;

#pragma mark - Status Operation

- (NSURL * _Nonnull)statusOperationUrlWithStatusId:(NSString * _Nonnull)statusId
                                     operationType:(MastodonClientStatusOperationType)type;

#pragma mark - OAuth

@property (readonly) BOOL isRegistered;

@property (nonatomic, strong, nullable) NSString *appId;

@property (nonatomic, strong, nullable) NSURL *redirectUri;

@property (nonatomic, strong, nullable) NSString *clientId;

@property (nonatomic, strong, nullable) NSString *clientSecret;

@end
