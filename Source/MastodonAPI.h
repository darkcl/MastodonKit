//
//  MastodonAPI.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 10/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonStatus, MastodonClient, MastodonAccount, MastodonRelationship;

@interface MastodonAPI : NSObject

+ (BOOL)launchMastodonKit;

#pragma mark - Clients Related

+ (void)createClient:(NSURL * _Nonnull)instanceUrl;

+ (void)removeClient:(MastodonClient * _Nonnull)client;

+ (NSArray <MastodonClient *> * _Nonnull)listAllClients;

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
                          successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
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

@end
