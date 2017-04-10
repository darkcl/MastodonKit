//
//  MastodonAPI.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 10/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonAPI.h"

#import "MastodonClientManager.h"

#import "MastodonClientManagerBuilder.h"

#import "MastodonConstants.h"

#import "MastodonClient.h"

@interface MastodonAPI ()  {
    
}

@property (nonatomic, strong) MastodonClientManager *manager;

@end

@implementation MastodonAPI

+ (instancetype) sharedInstance
{
    static MastodonAPI *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MastodonAPI alloc] init];
    });
    return instance;
}

+ (BOOL)launchMastodonKit{
    MastodonAPI *api = [self sharedInstance];
    
    if (api.manager == nil) {
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:MastodonKitApplicationName];
        NSAssert(appName != nil, @"Add 'MastodonKitApplicationName' for Application Name in Info.plist");
        
        NSString *redirectUri = [[NSBundle mainBundle] objectForInfoDictionaryKey:MastodonKitRedirectUri];
        NSAssert(redirectUri != nil, @"Add 'MastodonKitRedirectUri' for Redirect Uri (For example: myApp://oauth) in Info.plist");
        
        NSString *websiteUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:MastodonKitWebsitUrl];
        
        api.manager = [[MastodonClientManager alloc] initWithBlock:^(MastodonClientManagerBuilder * _Nonnull builder) {
            builder.applicationName = appName;
            builder.redirectUri = redirectUri;
            builder.websiteUrl = websiteUrl;
        }];
        return YES;
    }else{
        return YES;
    }
}

#pragma mark - Clients Related

+ (void)createClient:(NSURL * _Nonnull)instanceUrl{
    [[[self sharedInstance] manager] createClient:instanceUrl];
}

+ (void)removeClient:(MastodonClient * _Nonnull)client{
    [[[self sharedInstance] manager] removeClient:client];
}

+ (NSArray <MastodonClient *> * _Nonnull)listAllClients{
    NSArray <MastodonClient *> *result =  [[self sharedInstance] manager].clientsList;
    if (result) {
        return result;
    }else{
        return @[];
    }
}

#pragma mark - Login Related

+ (void)loginWithClient:(MastodonClient * _Nonnull)client
           successBlock:(void(^ _Nullable)(void))successBlock
           failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager loginWithClient:client
                      completion:^(BOOL success, NSURL * _Nullable authUrl, NSError * _Nullable error) {
                          if (success) {
                              successBlock();
                          }else{
                              failureBlock(error);
                          }
                      }];
}

#pragma mark - Fetching Account
+ (void)fetchAccountInfoWithClient:(MastodonClient * _Nonnull)client
                         accountId:(NSString * _Nonnull)accountId
                      successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                      failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountInfoWithClient:client
                                  accountId:accountId
                                 completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                     if (success) {
                                         successBlock(response);
                                     }else{
                                         failureBlock(error);
                                     }
                                 }];
}

+ (void)fetchCurentUserAccountInfoWithClient:(MastodonClient * _Nonnull)client
                                successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                                failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserAccountInfoWithClient:client
                                           completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                               if (success) {
                                                   successBlock(response);
                                               }else{
                                                   failureBlock(error);
                                               }
                                           }];
}

+ (void)fetchAccountFollowersWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountFollowersWithClient:client
                                       accountId:accountId
                                           maxId:maxId
                                         sinceId:sinceId
                                           limit:limit
                                      completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                          if (success) {
                                              successBlock(response);
                                          }else{
                                              failureBlock(error);
                                          }
                                      }];
    
}

+ (void)fetchAccountFollowingWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountFollowingWithClient:client
                                       accountId:accountId
                                           maxId:maxId
                                         sinceId:sinceId
                                           limit:limit
                                      completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                          if (success) {
                                              successBlock(response);
                                          }else{
                                              failureBlock(error);
                                          }
                                      }];
}

+ (void)fetchAccountStatusesWithClient:(MastodonClient * _Nonnull)client
                             accountId:(NSString * _Nonnull)accountId
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                          successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                          failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountStatusesWithClient:client
                                      accountId:accountId
                                          maxId:maxId
                                        sinceId:sinceId
                                          limit:limit
                                     completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                         if (success) {
                                             successBlock(response);
                                         }else{
                                             failureBlock(error);
                                         }
                                     }];
}

#pragma mark - Fetching Timeline

+ (void)fetchHomeTimeline:(MastodonClient * _Nonnull)client
                    maxId:(NSString * _Nullable)maxId
                  sinceId:(NSString * _Nullable)sinceId
                    limit:(NSInteger)limit
             successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchHomeTimelineWithClient:client
                                       maxId:maxId
                                     sinceId:sinceId
                                       limit:limit
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                      if (success) {
                                          successBlock(response);
                                      }else{
                                          failureBlock(error);
                                      }
                                  }];
}

+ (void)fetchLocalTimeline:(MastodonClient * _Nonnull)client
                     maxId:(NSString * _Nullable)maxId
                   sinceId:(NSString * _Nullable)sinceId
                     limit:(NSInteger)limit
              successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
              failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchLocalTimelineWithClient:client
                                        maxId:maxId
                                      sinceId:sinceId
                                        limit:limit
                                   completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                       if (success) {
                                           successBlock(response);
                                       }else{
                                           failureBlock(error);
                                       }
                                   }];
}

+ (void)fetchPublicTimeline:(MastodonClient * _Nonnull)client
                      maxId:(NSString * _Nullable)maxId
                    sinceId:(NSString * _Nullable)sinceId
                      limit:(NSInteger)limit
               successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
               failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchPublicTimelineWithClient:client
                                         maxId:maxId
                                       sinceId:sinceId
                                         limit:limit
                                    completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error) {
                                        if (success) {
                                            successBlock(response);
                                        }else{
                                            failureBlock(error);
                                        }
                                    }];
}

@end
