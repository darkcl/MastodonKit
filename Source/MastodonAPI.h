//
//  MastodonAPI.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 10/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonStatus, MastodonClient, MastodonAccount, MastodonRelationship, MastodonAttachment, MastodonNotification, MastodonReport, MastodonSearchResult, MastodonContext, MastodonCard;

#import "MastodonConstants.h"

@interface MastodonAPI : NSObject

+ (BOOL)launchMastodonKit;

#pragma mark - Clients Related

+ (void)createClient:(NSURL * _Nonnull)instanceUrl;

+ (void)removeClient:(MastodonClient * _Nonnull)client;

+ (NSArray <MastodonClient *> * _Nonnull)listAllClients;

+ (MastodonClient * _Nullable)lastUsedClient;

#pragma mark - Login Related

+ (void)loginWithClient:(MastodonClient * _Nonnull)client
           successBlock:(void(^ _Nullable)(void))successBlock
           failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

#pragma mark - Fetching Account

+ (void)fetchAccountInfoWithClient:(MastodonClient * _Nonnull)client
                         accountId:(NSString * _Nonnull)accountId
                      successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                      failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)fetchAccountFollowersWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchAccountFollowingWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchAccountStatusesWithClient:(MastodonClient * _Nonnull)client
                             accountId:(NSString * _Nonnull)accountId
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                             onlyMedia:(BOOL)onlyMedia
                        excludeReplies:(BOOL)excludeReplies
                          successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
                          failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchAccountRelationshipsWithClient:(MastodonClient * _Nonnull)client
                                 accountIds:(NSArray <NSString *> * _Nonnull)accountIds
                               successBlock:(void(^ _Nullable)(NSArray <MastodonRelationship *> * _Nullable result))successBlock
                               failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Fetching Current Account

+ (void)fetchCurentUserAccountInfoWithClient:(MastodonClient * _Nonnull)client
                                successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                                failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)fetchCurentUserBlocksWithClient:(MastodonClient * _Nonnull)client
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchCurentUserMutesWithClient:(MastodonClient * _Nonnull)client
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                          successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                          failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchCurentUserStatusesWithClient:(MastodonClient * _Nonnull)client
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                             successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
                             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchCurentUserFollowRequestsWithClient:(MastodonClient * _Nonnull)client
                                          maxId:(NSString * _Nullable)maxId
                                        sinceId:(NSString * _Nullable)sinceId
                                          limit:(NSInteger)limit
                                   successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                                   failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Notification

+ (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                       successBlock:(void(^ _Nullable)(NSArray <MastodonNotification *> * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                     notificationId:(NSString * _Nonnull)notificationId
                       successBlock:(void(^ _Nullable)(MastodonNotification * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)clearNotificationWithClient:(MastodonClient * _Nonnull)client
                       successBlock:(void(^ _Nullable)(void))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Reports

+ (void)fetchReportsWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                       successBlock:(void(^ _Nullable)(NSArray <MastodonReport *> * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)reportUserWithClient:(MastodonClient * _Nonnull)client
                         accoutId:(NSString * _Nonnull)accoutId
                   statusIds:(NSArray <NSString *> * _Nonnull)statusIds
                     comment:(NSString * _Nonnull)comment
                  successBlock:(void(^ _Nullable)(MastodonReport * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Search

+ (void)searchWithClient:(MastodonClient * _Nonnull)client
             queryString:(NSString * _Nonnull)queryString
      shouldResolveLocal:(BOOL)shouldResolveLocal
            successBlock:(void(^ _Nullable)(MastodonSearchResult * _Nullable result))successBlock
            failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Statuses

+ (void)fetchStatusWithClient:(MastodonClient * _Nonnull)client
                     statusId:(NSString * _Nonnull)statusId
                 successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                 failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchStatusContextWithClient:(MastodonClient * _Nonnull)client
                            statusId:(NSString * _Nonnull)statusId
                        successBlock:(void(^ _Nullable)(MastodonContext * _Nullable result))successBlock
                        failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchStatusCardWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                     successBlock:(void(^ _Nullable)(MastodonCard * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchStatusRebloggedByWithClient:(MastodonClient * _Nonnull)client
                                statusId:(NSString * _Nonnull)statusId
                                   maxId:(NSString * _Nullable)maxId
                                 sinceId:(NSString * _Nullable)sinceId
                                   limit:(NSInteger)limit
                            successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                            failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchStatusFavouritedByWithClient:(MastodonClient * _Nonnull)client
                                 statusId:(NSString * _Nonnull)statusId
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                             successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Statuses Operation

+ (void)postStatusWithClient:(MastodonClient * _Nonnull)client
               statusContent:(NSString * _Nonnull)statusContent
             replyToStatusId:(NSString * _Nullable)replyToStatusId
                    mediaIds:(NSArray <NSString *> * _Nullable)mediaIds
                 isSensitive:(BOOL)isSensitive
                 spolierText:(NSString * _Nullable)spolierText
              postVisibility:(MastodonStatusVisibility)postVisibility
                successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)deleteStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                  successBlock:(void(^ _Nullable)(void))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)reblogStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                  successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)unreblogStatusWithClient:(MastodonClient * _Nonnull)client
                        statusId:(NSString * _Nonnull)statusId
                    successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                    failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)favouriteStatusWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                     successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)unfavouriteStatusWithClient:(MastodonClient * _Nonnull)client
                           statusId:(NSString * _Nonnull)statusId
                       successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Account Operation

+ (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)unfollowAccountWithClient:(MastodonClient * _Nonnull)client
                    withAccountId:(NSString * _Nonnull)accountId
                     successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)blockAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountId:(NSString * _Nonnull)accountId
                  successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)unblockAccountWithClient:(MastodonClient * _Nonnull)client
                   withAccountId:(NSString * _Nonnull)accountId
                    successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                    failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)muteAccountWithClient:(MastodonClient * _Nonnull)client
                withAccountId:(NSString * _Nonnull)accountId
                 successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                 failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)unmuteAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)apporveFollowRequestWithClient:(MastodonClient * _Nonnull)client
                         withAccountId:(NSString * _Nonnull)accountId
                          successBlock:(void(^ _Nullable)(void))successBlock
                          failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)rejectFollowRequestWithClient:(MastodonClient * _Nonnull)client
                        withAccountId:(NSString * _Nonnull)accountId
                         successBlock:(void(^ _Nullable)(void))successBlock
                         failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

+ (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountUri:(NSString * _Nonnull)accountUri
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock;

#pragma mark - Fetching Timeline

+ (void)fetchHomeTimeline:(MastodonClient * _Nonnull)client
                    maxId:(NSString * _Nullable)maxId
                  sinceId:(NSString * _Nullable)sinceId
                    limit:(NSInteger)limit
             successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchLocalTimeline:(MastodonClient * _Nonnull)client
                     maxId:(NSString * _Nullable)maxId
                   sinceId:(NSString * _Nullable)sinceId
                     limit:(NSInteger)limit
              successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
              failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

+ (void)fetchPublicTimeline:(MastodonClient * _Nonnull)client
                      maxId:(NSString * _Nullable)maxId
                    sinceId:(NSString * _Nullable)sinceId
                      limit:(NSInteger)limit
               successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
               failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

#pragma mark - Upload Media

+ (void)uploadFileWithClient:(MastodonClient * _Nonnull)client
                    fileData:(NSData * _Nonnull)fileData
               progressBlock:(void (^ _Nullable)(double progress))progressBlock
                successBlock:(void(^ _Nullable)(MastodonAttachment * _Nullable result))successBlock
                failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock;

@end
