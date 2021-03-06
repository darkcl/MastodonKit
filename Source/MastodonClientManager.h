//
//  MastodonClientManager.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonConstants.h"

@class MastodonClientManagerBuilder, MastodonClient;

typedef void(^MastodonClientManagerBuildBlock)(MastodonClientManagerBuilder * _Nonnull builder);

typedef void(^MastodonClientManagerCompletionBlock)(BOOL success, NSError * _Nullable error);

typedef void(^MastodonClientManagerLoginCompletionBlock)(BOOL success, NSURL * _Nullable authUrl, NSError * _Nullable error);

typedef void(^MastodonClientRequestComplationBlock)(BOOL success, _Nullable id response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId);

typedef void(^MastodonClientRequestProgessBlock)(double progress);

@interface MastodonClientManager : NSObject

- (_Nonnull instancetype)initWithBlock:(_Nonnull MastodonClientManagerBuildBlock)block;

- (MastodonClient * _Nonnull)createClient:(NSURL * _Nullable)instanceUrl;

- (void)removeClient:(MastodonClient * _Nonnull)client;

- (MastodonClient * _Nullable)getClientWithInstanceUrl:(NSURL * _Nonnull)instanceUrl;

@property (nonatomic, strong, nullable) NSString *appGroupIdentifier;

#pragma mark - Login / Authenticate

- (void)registerApplicationWithClient:(MastodonClient * _Nonnull)client
                           completion:(MastodonClientManagerCompletionBlock _Nullable)completionBlock;

- (void)loginWithClient:(MastodonClient * _Nonnull)client
             completion:(MastodonClientManagerLoginCompletionBlock _Nullable)completionBlock;

#pragma mark - Fetching Account Information

- (void)fetchAccountInfoWithClient:(MastodonClient * _Nonnull)client
                         accountId:(NSString * _Nonnull)accountId
                        completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchAccountFollowersWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;


- (void)fetchAccountFollowingWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchAccountStatusesWithClient:(MastodonClient * _Nonnull)client
                             accountId:(NSString * _Nonnull)accountId
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                             onlyMedia:(BOOL)onlyMedia
                        excludeReplies:(BOOL)excludeReplies
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchAccountRelationshipsWithClient:(MastodonClient * _Nonnull)client
                                 accountIds:(NSArray <NSString *> * _Nonnull)accountIds
                                 completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Fetching Curent Account Information

- (void)fetchCurentUserAccountInfoWithClient:(MastodonClient * _Nonnull)client
                                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchCurentUserBlocksWithClient:(MastodonClient * _Nonnull)client
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchCurentUserMutesWithClient:(MastodonClient * _Nonnull)client
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchCurentUserStatusesWithClient:(MastodonClient * _Nonnull)client
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                               completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchCurentUserFollowRequestsWithClient:(MastodonClient * _Nonnull)client
                                          maxId:(NSString * _Nullable)maxId
                                        sinceId:(NSString * _Nullable)sinceId
                                          limit:(NSInteger)limit
                                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Notification

- (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                     notificationId:(NSString * _Nonnull)notificationId
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)clearNotificationWithClient:(MastodonClient * _Nonnull)client
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Reports

- (void)fetchReportsWithClient:(MastodonClient * _Nonnull)client
                         maxId:(NSString * _Nullable)maxId
                       sinceId:(NSString * _Nullable)sinceId
                         limit:(NSInteger)limit
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)reportUserWithClient:(MastodonClient * _Nonnull)client
                    accoutId:(NSString * _Nonnull)accoutId
                   statusIds:(NSArray <NSString *> * _Nonnull)statusIds
                     comment:(NSString * _Nonnull)comment
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Search

- (void)searchWithClient:(MastodonClient * _Nonnull)client
             queryString:(NSString * _Nonnull)queryString
      shouldResolveLocal:(BOOL)shouldResolveLocal
              completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Statuses

- (void)fetchStatusWithClient:(MastodonClient * _Nonnull)client
                     statusId:(NSString * _Nonnull)statusId
                   completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchStatusContextWithClient:(MastodonClient * _Nonnull)client
                            statusId:(NSString * _Nonnull)statusId
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchStatusCardWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchStatusRebloggedByWithClient:(MastodonClient * _Nonnull)client
                                statusId:(NSString * _Nonnull)statusId
                                   maxId:(NSString * _Nullable)maxId
                                 sinceId:(NSString * _Nullable)sinceId
                                   limit:(NSInteger)limit
                              completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchStatusFavouritedByWithClient:(MastodonClient * _Nonnull)client
                                 statusId:(NSString * _Nonnull)statusId
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                               completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Statuses Operation

- (void)postStatusWithClient:(MastodonClient * _Nonnull)client
               statusContent:(NSString * _Nonnull)statusContent
             replyToStatusId:(NSString * _Nullable)replyToStatusId
                    mediaIds:(NSArray <NSString *> * _Nullable)mediaIds
                 isSensitive:(BOOL)isSensitive
                 spolierText:(NSString * _Nullable)spolierText
              postVisibility:(MastodonStatusVisibility)postVisibility
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)deleteStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)reblogStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)unreblogStatusWithClient:(MastodonClient * _Nonnull)client
                        statusId:(NSString * _Nonnull)statusId
                      completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)favouriteStatusWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)unfavouriteStatusWithClient:(MastodonClient * _Nonnull)client
                           statusId:(NSString * _Nonnull)statusId
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Account Operation

- (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)unfollowAccountWithClient:(MastodonClient * _Nonnull)client
                    withAccountId:(NSString * _Nonnull)accountId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)blockAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountId:(NSString * _Nonnull)accountId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)unblockAccountWithClient:(MastodonClient * _Nonnull)client
                   withAccountId:(NSString * _Nonnull)accountId
                      completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)muteAccountWithClient:(MastodonClient * _Nonnull)client
                withAccountId:(NSString * _Nonnull)accountId
                   completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)unmuteAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)apporveFollowRequestWithClient:(MastodonClient * _Nonnull)client
                         withAccountId:(NSString * _Nonnull)accountId
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)rejectFollowRequestWithClient:(MastodonClient * _Nonnull)client
                        withAccountId:(NSString * _Nonnull)accountId
                           completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountUri:(NSString * _Nonnull)accountUri
                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Fetching Timeline

- (void)fetchTagsTimelineWithClient:(MastodonClient * _Nonnull)client
                                tag:(NSString * _Nonnull)tag
                            isLocal:(BOOL)isLocal
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchHomeTimelineWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchLocalTimelineWithClient:(MastodonClient * _Nonnull)client
                               maxId:(NSString * _Nullable)maxId
                             sinceId:(NSString * _Nullable)sinceId
                               limit:(NSInteger)limit
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

- (void)fetchPublicTimelineWithClient:(MastodonClient * _Nonnull)client
                                maxId:(NSString * _Nullable)maxId
                              sinceId:(NSString * _Nullable)sinceId
                                limit:(NSInteger)limit
                           completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

#pragma mark - Upload Media

- (void)uploadFileWithClient:(MastodonClient * _Nonnull)client
                    fileData:(NSData * _Nonnull)fileData
                    progress:(MastodonClientRequestProgessBlock _Nullable)progressBlock
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock;

@property (nonatomic, strong, nonnull) NSString *applicationName;

@property (nonatomic, strong, nonnull) NSString *redirectUri;

@property (nonatomic, strong, nonnull) NSSet <NSString *> *scopes;

@property (nonatomic, strong, nullable) NSString *websiteUrl;

@property (nonatomic, strong, nullable) NSArray <MastodonClient *> *clientsList;

@end
