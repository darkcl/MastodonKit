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

+ (BOOL)launchMastodonKitWithAppGroupIdentifier:(NSString *_Nonnull)identifier{
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
        
        api.manager.appGroupIdentifier = identifier;
        
        return YES;
    }else{
        return YES;
    }
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

+ (MastodonClient * _Nullable)lastUsedClient{
    NSString *lastUsedUrl = [[NSUserDefaults standardUserDefaults] valueForKey:MastodonKitLastUsedClientKey];
    
    NSURL *url = [NSURL URLWithString:lastUsedUrl];
    
    if (url) {
        MastodonAPI *api = [self sharedInstance];
        return [api.manager getClientWithInstanceUrl:url];
    }else{
        return nil;
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

#pragma mark - Notification

+ (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                       successBlock:(void(^ _Nullable)(NSArray <MastodonNotification *> * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchNotificationWithClient:client
                                       maxId:maxId
                                     sinceId:sinceId
                                       limit:limit
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                      if (success) {
                                          successBlock(response);
                                      }else{
                                          failureBlock(error);
                                      }
                                  }];
}

+ (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                     notificationId:(NSString * _Nonnull)notificationId
                       successBlock:(void(^ _Nullable)(MastodonNotification * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchNotificationWithClient:client
                              notificationId:notificationId
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                      if (success) {
                                          successBlock(response);
                                      }else{
                                          failureBlock(error);
                                      }
                                  }];
}

+ (void)clearNotificationWithClient:(MastodonClient * _Nonnull)client
                       successBlock:(void(^ _Nullable)(void))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager clearNotificationWithClient:client
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                      if (success) {
                                          successBlock();
                                      }else{
                                          failureBlock(error);
                                      }
                                  }];
}

#pragma mark - Reports

+ (void)fetchReportsWithClient:(MastodonClient * _Nonnull)client
                         maxId:(NSString * _Nullable)maxId
                       sinceId:(NSString * _Nullable)sinceId
                         limit:(NSInteger)limit
                  successBlock:(void(^ _Nullable)(NSArray <MastodonReport *> * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchReportsWithClient:client
                                  maxId:maxId
                                sinceId:sinceId
                                  limit:limit
                             completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                 if (success) {
                                     successBlock(response);
                                 }else{
                                     failureBlock(error);
                                 }
                             }];
}

+ (void)reportUserWithClient:(MastodonClient * _Nonnull)client
                    accoutId:(NSString * _Nonnull)accoutId
                   statusIds:(NSArray <NSString *> * _Nonnull)statusIds
                     comment:(NSString * _Nonnull)comment
                successBlock:(void(^ _Nullable)(MastodonReport * _Nullable result))successBlock
                failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager reportUserWithClient:client
                             accoutId:accoutId
                            statusIds:statusIds
                              comment:comment
                           completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                               if (success) {
                                   successBlock(response);
                               }else{
                                   failureBlock(error);
                               }
                           }];
}

#pragma mark - Search

+ (void)searchWithClient:(MastodonClient * _Nonnull)client
             queryString:(NSString * _Nonnull)queryString
      shouldResolveLocal:(BOOL)shouldResolveLocal
            successBlock:(void(^ _Nullable)(MastodonSearchResult * _Nullable result))successBlock
            failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager searchWithClient:client
                      queryString:queryString
               shouldResolveLocal:shouldResolveLocal
                       completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                           if (success) {
                               successBlock(response);
                           }else{
                               failureBlock(error);
                           }
                       }];
}

#pragma mark - Statuses

+ (void)fetchStatusWithClient:(MastodonClient * _Nonnull)client
                     statusId:(NSString * _Nonnull)statusId
                 successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                 failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchStatusWithClient:client
                              statusId:statusId
                            completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                if (success) {
                                    successBlock(response);
                                }else{
                                    failureBlock(error);
                                }
                            }];
}

+ (void)fetchStatusContextWithClient:(MastodonClient * _Nonnull)client
                            statusId:(NSString * _Nonnull)statusId
                        successBlock:(void(^ _Nullable)(MastodonContext * _Nullable result))successBlock
                        failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchStatusContextWithClient:client
                                     statusId:statusId
                                   completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                       if (success) {
                                           successBlock(response);
                                       }else{
                                           failureBlock(error);
                                       }
                                   }];
    
}

+ (void)fetchStatusCardWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                     successBlock:(void(^ _Nullable)(MastodonCard * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchStatusCardWithClient:client
                                  statusId:statusId
                                completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                    if (success) {
                                        successBlock(response);
                                    }else{
                                        failureBlock(error);
                                    }
                                }];
}

+ (void)fetchStatusRebloggedByWithClient:(MastodonClient * _Nonnull)client
                                statusId:(NSString * _Nonnull)statusId
                                   maxId:(NSString * _Nullable)maxId
                                 sinceId:(NSString * _Nullable)sinceId
                                   limit:(NSInteger)limit
                            successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                            failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchStatusRebloggedByWithClient:client
                                         statusId:statusId
                                            maxId:maxId
                                          sinceId:sinceId
                                            limit:limit
                                       completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                           if (success) {
                                               successBlock(response);
                                           }else{
                                               failureBlock(error);
                                           }
                                       }];
}

+ (void)fetchStatusFavouritedByWithClient:(MastodonClient * _Nonnull)client
                                 statusId:(NSString * _Nonnull)statusId
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                             successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchStatusFavouritedByWithClient:client
                                          statusId:statusId
                                             maxId:maxId
                                           sinceId:sinceId
                                             limit:limit
                                        completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                            if (success) {
                                                successBlock(response);
                                            }else{
                                                failureBlock(error);
                                            }
                                        }];
}

#pragma mark - Statuses Operation

+ (void)postStatusWithClient:(MastodonClient * _Nonnull)client
               statusContent:(NSString * _Nonnull)statusContent
             replyToStatusId:(NSString * _Nullable)replyToStatusId
                    mediaIds:(NSArray <NSString *> * _Nullable)mediaIds
                 isSensitive:(BOOL)isSensitive
                 spolierText:(NSString * _Nullable)spolierText
              postVisibility:(MastodonStatusVisibility)postVisibility
                successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager postStatusWithClient:client
                        statusContent:statusContent
                      replyToStatusId:replyToStatusId
                             mediaIds:mediaIds
                          isSensitive:isSensitive
                          spolierText:spolierText
                       postVisibility:postVisibility
                           completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                               if (success) {
                                   successBlock(response);
                               }else{
                                   failureBlock(error);
                               }
                           }];
}

+ (void)deleteStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                  successBlock:(void(^ _Nullable)(void))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager deleteStatusWithClient:client
                               statusId:statusId
                             completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                 if (success) {
                                     successBlock();
                                 }else{
                                     failureBlock(error);
                                 }
                             }];
    
}

+ (void)reblogStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                  successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager reblogStatusWithClient:client
                               statusId:statusId
                             completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                 if (success) {
                                     successBlock(response);
                                 }else{
                                     failureBlock(error);
                                 }
                             }];
}

+ (void)unreblogStatusWithClient:(MastodonClient * _Nonnull)client
                        statusId:(NSString * _Nonnull)statusId
                    successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                    failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager unreblogStatusWithClient:client
                               statusId:statusId
                             completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                 if (success) {
                                     successBlock(response);
                                 }else{
                                     failureBlock(error);
                                 }
                             }];
}

+ (void)favouriteStatusWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                     successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager favouriteStatusWithClient:client
                                 statusId:statusId
                               completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                   if (success) {
                                       successBlock(response);
                                   }else{
                                       failureBlock(error);
                                   }
                               }];
}

+ (void)unfavouriteStatusWithClient:(MastodonClient * _Nonnull)client
                           statusId:(NSString * _Nonnull)statusId
                       successBlock:(void(^ _Nullable)(MastodonStatus * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager unfavouriteStatusWithClient:client
                                  statusId:statusId
                                completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                    if (success) {
                                        successBlock(response);
                                    }else{
                                        failureBlock(error);
                                    }
                                }];
}

#pragma mark - Account Operation

+ (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager followAccountWithClient:client
                           withAccountId:accountId
                              completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                  if (success) {
                                      successBlock(response);
                                  }else{
                                      failureBlock(error);
                                  }
                              }];
}

+ (void)unfollowAccountWithClient:(MastodonClient * _Nonnull)client
                    withAccountId:(NSString * _Nonnull)accountId
                     successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                     failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager unfollowAccountWithClient:client
                             withAccountId:accountId
                                completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                    if (success) {
                                        successBlock(response);
                                    }else{
                                        failureBlock(error);
                                    }
                                }];
}

+ (void)blockAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountId:(NSString * _Nonnull)accountId
                  successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                  failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager blockAccountWithClient:client
                          withAccountId:accountId
                             completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                 if (success) {
                                     successBlock(response);
                                 }else{
                                     failureBlock(error);
                                 }
                             }];
}

+ (void)unblockAccountWithClient:(MastodonClient * _Nonnull)client
                   withAccountId:(NSString * _Nonnull)accountId
                    successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                    failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager unblockAccountWithClient:client
                            withAccountId:accountId
                               completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                   if (success) {
                                       successBlock(response);
                                   }else{
                                       failureBlock(error);
                                   }
                               }];
}

+ (void)muteAccountWithClient:(MastodonClient * _Nonnull)client
                withAccountId:(NSString * _Nonnull)accountId
                 successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                 failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager muteAccountWithClient:client
                         withAccountId:accountId
                            completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                if (success) {
                                    successBlock(response);
                                }else{
                                    failureBlock(error);
                                }
                            }];
}

+ (void)unmuteAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager unmuteAccountWithClient:client
                           withAccountId:accountId
                              completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                  if (success) {
                                      successBlock(response);
                                  }else{
                                      failureBlock(error);
                                  }
                              }];
}

+ (void)apporveFollowRequestWithClient:(MastodonClient * _Nonnull)client
                         withAccountId:(NSString * _Nonnull)accountId
                          successBlock:(void(^ _Nullable)(void))successBlock
                          failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager apporveFollowRequestWithClient:client
                                  withAccountId:accountId
                                     completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                         if (success) {
                                             successBlock();
                                         }else{
                                             failureBlock(error);
                                         }
                                     }];
}

+ (void)rejectFollowRequestWithClient:(MastodonClient * _Nonnull)client
                        withAccountId:(NSString * _Nonnull)accountId
                         successBlock:(void(^ _Nullable)(void))successBlock
                         failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager rejectFollowRequestWithClient:client
                                 withAccountId:accountId
                                    completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                        if (success) {
                                            successBlock();
                                        }else{
                                            failureBlock(error);
                                        }
                                    }];
}


+ (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountUri:(NSString * _Nonnull)accountUri
                   successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                   failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager followAccountWithClient:client
                          withAccountUri:accountUri
                              completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                  if (success) {
                                      successBlock(response);
                                  }else{
                                      failureBlock(error);
                                  }
                              }];
}

#pragma mark - Fetching Account

+ (void)fetchCurentUserAccountInfoWithClient:(MastodonClient * _Nonnull)client
                                successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                                failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserAccountInfoWithClient:client
                                           completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
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
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result, NSString * _Nullable maxId,  NSString * _Nullable sinceId))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountFollowersWithClient:client
                                       accountId:accountId
                                           maxId:maxId
                                         sinceId:sinceId
                                           limit:limit
                                      completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                          if (success) {
                                              successBlock(response,maxId,sinceId);
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
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result, NSString * _Nullable maxId,  NSString * _Nullable sinceId))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountFollowingWithClient:client
                                       accountId:accountId
                                           maxId:maxId
                                         sinceId:sinceId
                                           limit:limit
                                      completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                          if (success) {
                                              successBlock(response,maxId,sinceId);
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
                             onlyMedia:(BOOL)onlyMedia
                        excludeReplies:(BOOL)excludeReplies
                          successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
                          failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountStatusesWithClient:client
                                      accountId:accountId
                                          maxId:maxId
                                        sinceId:sinceId
                                          limit:limit
                                      onlyMedia:onlyMedia
                                 excludeReplies:excludeReplies
                                     completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                         if (success) {
                                             successBlock(response);
                                         }else{
                                             failureBlock(error);
                                         }
                                     }];
}

+ (void)fetchAccountRelationshipsWithClient:(MastodonClient * _Nonnull)client
                                 accountIds:(NSArray <NSString *> * _Nonnull)accountIds
                               successBlock:(void(^ _Nullable)(NSArray <MastodonRelationship *> * _Nullable result))successBlock
                               failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountRelationshipsWithClient:client
                                          accountIds:accountIds
                                          completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                              if (success) {
                                                  successBlock(response);
                                              }else{
                                                  failureBlock(error);
                                              }
                                          }];
}

#pragma mark - Fetching Current Account

+ (void)fetchAccountInfoWithClient:(MastodonClient * _Nonnull)client
                         accountId:(NSString * _Nonnull)accountId
                      successBlock:(void(^ _Nullable)(MastodonAccount * _Nullable result))successBlock
                      failureBlock:(void(^ _Nullable)(NSError *_Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchAccountInfoWithClient:client
                                  accountId:accountId
                                 completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                     if (success) {
                                         successBlock(response);
                                     }else{
                                         failureBlock(error);
                                     }
                                 }];
}

+ (void)fetchCurentUserBlocksWithClient:(MastodonClient * _Nonnull)client
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                           successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                           failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserBlocksWithClient:client
                                           maxId:maxId
                                         sinceId:sinceId
                                           limit:limit
                                      completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                          if (success) {
                                              successBlock(response);
                                          }else{
                                              failureBlock(error);
                                          }
                                      }];
}

+ (void)fetchCurentUserStatusesWithClient:(MastodonClient * _Nonnull)client
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                             successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
                             failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserStatusesWithClient:client
                                             maxId:maxId
                                           sinceId:sinceId
                                             limit:limit
                                        completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                            if (success) {
                                                successBlock(response);
                                            }else{
                                                failureBlock(error);
                                            }
                                        }];
}

+ (void)fetchCurentUserFollowRequestsWithClient:(MastodonClient * _Nonnull)client
                                          maxId:(NSString * _Nullable)maxId
                                        sinceId:(NSString * _Nullable)sinceId
                                          limit:(NSInteger)limit
                                   successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                                   failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserFollowRequestsWithClient:client
                                                   maxId:maxId
                                                 sinceId:sinceId
                                                   limit:limit
                                              completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                                  if (success) {
                                                      successBlock(response);
                                                  }else{
                                                      failureBlock(error);
                                                  }
                                              }];
    
}

+ (void)fetchCurentUserMutesWithClient:(MastodonClient * _Nonnull)client
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                          successBlock:(void(^ _Nullable)(NSArray <MastodonAccount *> * _Nullable result))successBlock
                          failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchCurentUserMutesWithClient:client
                                          maxId:maxId
                                        sinceId:sinceId
                                          limit:limit
                                     completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
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
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
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
                                   completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
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
                                    completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                                        if (success) {
                                            successBlock(response);
                                        }else{
                                            failureBlock(error);
                                        }
                                    }];
}

+ (void)fetchTagsTimelineWithClient:(MastodonClient * _Nonnull)client
                                tag:(NSString * _Nonnull)tag
                            isLocal:(BOOL)isLocal
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                       successBlock:(void(^ _Nullable)(NSArray <MastodonStatus *> * _Nullable result))successBlock
                       failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager fetchTagsTimelineWithClient:client
                                         tag:tag
                                     isLocal:isLocal
                                       maxId:maxId
                                     sinceId:sinceId
                                       limit:limit
                                  completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId, NSString * _Nullable sinceId) {
                                      if (success) {
                                          successBlock(response);
                                      }else{
                                          failureBlock(error);
                                      }
                                  }];
}

#pragma mark - Upload Media

+ (void)uploadFileWithClient:(MastodonClient * _Nonnull)client
                    fileData:(NSData * _Nonnull)fileData
               progressBlock:(void (^ _Nullable)(double progress))progressBlock
                successBlock:(void(^ _Nullable)(MastodonAttachment * _Nullable result))successBlock
                failureBlock:(void(^ _Nullable)(NSError * _Nullable err))failureBlock{
    MastodonAPI *api = [self sharedInstance];
    
    [api.manager uploadFileWithClient:client
                             fileData:fileData
                             progress:^(double progress) {
                                 progressBlock(progress);
                             }
                           completion:^(BOOL success, id  _Nullable response, NSError * _Nullable error, NSString * _Nullable maxId,  NSString * _Nullable sinceId) {
                               if (success) {
                                   successBlock(response);
                               }else{
                                   failureBlock(error);
                               }
                           }];
}

@end
