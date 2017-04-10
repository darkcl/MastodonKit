//
//  MastodonAPI.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 10/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonStatus, MastodonClient;

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

#pragma mark - Timeline Related

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
