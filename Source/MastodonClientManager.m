//
//  MastodonClientManager.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClientManager.h"

#import "MastodonClientManagerBuilder.h"

#import "MastodonClient.h"

#import "MastodonAccount.h"

#import "MastodonAttachment.h"

#import "MastodonNotification.h"

#import "MastodonSearchResult.h"

#import "NSError+MastodonKit.h"

#import "MastodonStatus.h"

#import "MastodonContext.h"

#import "MastodonRelationship.h"

#import "MastodonReport.h"

#import "MastodonCard.h"

#import "NSURL+MastodonKit.h"

#ifdef COCOAPODS
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

#import "NSDictionary+MastodonKit.h"

#import "NSUserDefaults+MastodonKit.h"

#if TARGET_OS_IOS

#import "MastodonLoginViewController.h"

#endif

@interface MastodonClientManager() {
    NSMutableDictionary <NSString *, MastodonClientManagerLoginCompletionBlock> *loginCompletionBlocks;
}

@end

@implementation MastodonClientManager

- (instancetype)initWithBlock:(MastodonClientManagerBuildBlock)buildBlock{
    MastodonClientManagerBuilder *managerBuilder = [[MastodonClientManagerBuilder alloc] init];
    buildBlock(managerBuilder);
    MastodonClientManager *result = [managerBuilder build];
    [result setUpAllClient];
    return result;
}

- (void)setUpAllClient{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    for (MastodonClient *client in clients) {
        [self setUpClient:client];
    }
}

- (void)setUpClient:(MastodonClient *)client{
    if (client.isRegistered) {
        [[NXOAuth2AccountStore sharedStore] setClientID:client.clientId
                                                 secret:client.clientSecret
                                       authorizationURL:client.authUrl
                                               tokenURL:client.tokenUrl
                                            redirectURL:client.redirectUri
                                         forAccountType:[self serviceNameWithClient:client]];
    }
}

- (MastodonClient * _Nonnull)createClient:(NSURL * _Nullable)instanceUrl{
    MastodonClient *client;
    
    if (instanceUrl != nil) {
        client = [MastodonClient clientWithInstanceURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://%@", instanceUrl.scheme, instanceUrl.host]]];
    }else{
        client = [MastodonClient clientWithInstanceURL:[NSURL URLWithString:@"https://mastodon.social"]];
    }
    
    NSMutableArray *clients = [[NSMutableArray alloc] initWithArray:self.clientsList];
    
    if (![clients containsObject:client]) {
        [clients addObject:client];
        
        self.clientsList = [NSArray arrayWithArray:clients];
        
        return client;
    }else{
        return [clients objectAtIndex:[clients indexOfObject:client]];
    }
}

- (void)removeClient:(MastodonClient * _Nonnull)client{
    NSMutableArray *clients = [[NSMutableArray alloc] initWithArray:self.clientsList];
    
    if ([clients containsObject:client]) {
        // Remove all acount to this service
        
        NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
        
        for (NXOAuth2Account *account in accounts) {
            [[NXOAuth2AccountStore sharedStore] removeAccount:account];
        }
        
        for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
            if([[cookie domain] isEqualToString:client.instanceUrl.host]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [clients removeObject:client];
        
        self.clientsList = [NSArray arrayWithArray:clients];
        
        
    }
}

- (void)registerApplicationWithClient:(MastodonClient * _Nonnull)client
                           completion:(MastodonClientManagerCompletionBlock _Nullable)completionBlock{
    NSURL *registerUrl = client.registerAppUrl;
    
    NSDictionary *params = @{@"client_name": self.applicationName,
                             @"redirect_uris": self.redirectUri,
                             @"scopes": [self.scopes.allObjects componentsJoinedByString:@" "],
                             @"website": self.websiteUrl ? self.websiteUrl : [NSNull null]};
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:registerUrl];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParameters:params]];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            completionBlock(NO, error);
        }else{
            NSError *parseError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (!responseObject) {
                completionBlock(NO, parseError);
            } else {
                NSString *appId = [responseObject stringOrNilForKey:@"id"];
                NSString *redirectUri = [responseObject stringOrNilForKey:@"redirect_uri"];
                NSString *clientId = [responseObject stringOrNilForKey:@"client_id"];
                NSString *clientSecret = [responseObject stringOrNilForKey:@"client_secret"];
                
                client.appId = appId;
                client.redirectUri = [NSURL URLWithString:redirectUri];
                client.clientId = clientId;
                client.clientSecret = clientSecret;
                
                if (client.isRegistered) {
                    [weakSelf setUpClient:client];
                    
                    [weakSelf updateClient:client];
                    
                    completionBlock(YES, nil);
                }else{
                    completionBlock(NO, [NSError errorWithDomain:@"com.darkcl.mastodon" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Something went wrong."}]);
                }
            }
        }
        
    }];
    [task resume];
}

- (NSString *)serviceNameWithClient:(MastodonClient *)client{
    return [NSString stringWithFormat:@"%@@%@",self.applicationName, client.instanceUrl.host];
}

- (void)loginWithClient:(MastodonClient * _Nonnull)client
             completion:(MastodonClientManagerLoginCompletionBlock _Nullable)completionBlock{
    if (client.isRegistered) {
        
        NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
        
        // TODO: Support Multiple Accounts
        
        __weak typeof(self) weakSelf = self;
        
        if (accounts.count != 0) {
            completionBlock(YES, nil, nil);
        }else{
            [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:[self serviceNameWithClient:client]
                                           withPreparedAuthorizationURLHandler:^(NSURL *preparedURL){
#if TARGET_OS_IOS
                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                   [MastodonLoginViewController showLoginViewWithUrl:preparedURL
                                                                                     withRedirectUri:[NSURL URLWithString:weakSelf.redirectUri]
                                                                                             success:^{
                                                                                                 client.isAuthorized = YES;
                                                                                                 
                                                                                                 [weakSelf updateClient:client];
                                                                                                 
                                                                                                 completionBlock(YES, nil, nil);
                                                                                             }
                                                                                              cancel:^{
                                                                                                  completionBlock(NO, nil, [NSError loginCancelError]);
                                                                                              }
                                                                                             failure:^(NSError *error) {
                                                                                                 completionBlock(NO, nil, error);
                                                                                             }];
                                               });
                                               
                                               
                                               
#else
                                               completionBlock(NO, preparedURL, nil);
#endif
                                           }];
        }
    }else{
        __weak typeof(self) weakSelf = self;
        
        [self registerApplicationWithClient:client
                                 completion:^(BOOL success, NSError * _Nullable error) {
                                     if (success) {
                                         [weakSelf loginWithClient:client
                                                        completion:completionBlock];
                                     }else{
                                         completionBlock(NO, nil, error);
                                     }
                                 }];
    }
}
- (void)fetchAccountRelationshipsWithClient:(MastodonClient * _Nonnull)client
                                 accountIds:(NSArray <NSString *> * _Nonnull)accountIds
                                 completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client accountRelationshipUrlWithAccountIds:accountIds]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonRelationship alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Notification

- (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.notificationUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonNotification alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchNotificationWithClient:(MastodonClient * _Nonnull)client
                     notificationId:(NSString * _Nonnull)notificationId
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client notificationUrlWithNotificationId:notificationId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonAccount alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)clearNotificationWithClient:(MastodonClient * _Nonnull)client
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:client.clearNotificationUrl
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                completionBlock(YES, responseData, nil);
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Reports

- (void)fetchReportsWithClient:(MastodonClient * _Nonnull)client
                         maxId:(NSString * _Nullable)maxId
                       sinceId:(NSString * _Nullable)sinceId
                         limit:(NSInteger)limit
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.reportUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonReport alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)reportUserWithClient:(MastodonClient * _Nonnull)client
                    accoutId:(NSString * _Nonnull)accoutId
                   statusIds:(NSArray <NSString *> * _Nonnull)statusIds
                     comment:(NSString * _Nonnull)comment
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (accoutId != nil) {
            [param setValue:accoutId forKey:@"account_id"];
        }
        
        if (statusIds != nil) {
            [param setValue:statusIds forKey:@"status_ids"];
        }
        
        if (comment != nil) {
            [param setValue:comment forKey:@"comment"];
        }
        
        [self performMethod:@"POST"
                 onResource:client.reportUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonReport alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Search

- (void)searchWithClient:(MastodonClient * _Nonnull)client
             queryString:(NSString * _Nonnull)queryString
      shouldResolveLocal:(BOOL)shouldResolveLocal
              completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (queryString != nil) {
            [param setValue:queryString forKey:@"q"];
        }
        
        [param setValue:@(shouldResolveLocal).stringValue forKey:@"resolve"];
        
        [self performMethod:@"GET"
                 onResource:client.searchUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonSearchResult alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Statuses

- (void)fetchStatusWithClient:(MastodonClient * _Nonnull)client
                     statusId:(NSString * _Nonnull)statusId
                   completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client statusUrlWithStatusId:statusId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonStatus alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchStatusContextWithClient:(MastodonClient * _Nonnull)client
                            statusId:(NSString * _Nonnull)statusId
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client statusContextUrlWithStatusId:statusId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonContext alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchStatusCardWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client statusCardUrlWithStatusId:statusId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonCard alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchStatusRebloggedByWithClient:(MastodonClient * _Nonnull)client
                                statusId:(NSString * _Nonnull)statusId
                                   maxId:(NSString * _Nullable)maxId
                                 sinceId:(NSString * _Nullable)sinceId
                                   limit:(NSInteger)limit
                              completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:[client statusReblogUrlWithStatusId:statusId]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchStatusFavouritedByWithClient:(MastodonClient * _Nonnull)client
                                 statusId:(NSString * _Nonnull)statusId
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                               completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:[client statusFavouriteUrlWithStatusId:statusId]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Statuses Operation

- (void)statusesOperationWithClient:(MastodonClient * _Nonnull)client
                     withStatusId:(NSString * _Nonnull)statusId
                     operationType:(MastodonClientStatusOperationType)type
                        completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"POST"
                 onResource:[client statusOperationUrlWithStatusId:statusId operationType:type]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonStatus alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)postStatusWithClient:(MastodonClient * _Nonnull)client
               statusContent:(NSString * _Nonnull)statusContent
             replyToStatusId:(NSString * _Nullable)replyToStatusId
                    mediaIds:(NSArray <NSString *> * _Nullable)mediaIds
                 isSensitive:(BOOL)isSensitive
                 spolierText:(NSString * _Nullable)spolierText
              postVisibility:(MastodonStatusVisibility)postVisibility
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        
        if (statusContent != nil) {
            [params setObject:statusContent forKey:@"status"];
        }
        
        if (replyToStatusId != nil) {
            [params setObject:replyToStatusId forKey:@"in_reply_to_id"];
        }
        
        if (mediaIds != nil) {
            [params setObject:replyToStatusId forKey:@"media_ids"];
        }
        
        [params setObject:isSensitive ? @"true" : @"false" forKey:@"sensitive"];
        
        if (spolierText != nil) {
            [params setObject:spolierText forKey:@"spoiler_text"];
        }
        
        switch (postVisibility) {
            case MastodonStatusVisibilityPublic:
                [params setObject:@"public" forKey:@"visibility"];
                break;
            case MastodonStatusVisibilityUnlisted:
                [params setObject:@"unlisted" forKey:@"visibility"];
                break;
            case MastodonStatusVisibilityDirect:
                [params setObject:@"direct" forKey:@"visibility"];
                break;
            case MastodonStatusVisibilityPrivate:
                [params setObject:@"private" forKey:@"visibility"];
                break;
            default:
                break;
        }
        
        [self performMethod:@"POST"
                 onResource:[client.statusUrl urlWithParameters:params]
            usingParameters:params
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonStatus alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)deleteStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"DELETE"
                 onResource:[client statusUrlWithStatusId:statusId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonStatus alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)reblogStatusWithClient:(MastodonClient * _Nonnull)client
                      statusId:(NSString * _Nonnull)statusId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self statusesOperationWithClient:client
                        withStatusId:statusId
                        operationType:MastodonClientStatusOperationTypeReblog
                           completion:completionBlock];
}

- (void)unreblogStatusWithClient:(MastodonClient * _Nonnull)client
                        statusId:(NSString * _Nonnull)statusId
                      completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self statusesOperationWithClient:client
                         withStatusId:statusId
                        operationType:MastodonClientStatusOperationTypeUnreblog
                           completion:completionBlock];
}

- (void)favouriteStatusWithClient:(MastodonClient * _Nonnull)client
                         statusId:(NSString * _Nonnull)statusId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self statusesOperationWithClient:client
                         withStatusId:statusId
                        operationType:MastodonClientStatusOperationTypeFavourite
                           completion:completionBlock];
}

- (void)unfavouriteStatusWithClient:(MastodonClient * _Nonnull)client
                           statusId:(NSString * _Nonnull)statusId
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self statusesOperationWithClient:client
                         withStatusId:statusId
                        operationType:MastodonClientStatusOperationTypeUnfavourite
                           completion:completionBlock];
}

#pragma mark - Account Operation

- (void)accountOperationWithClient:(MastodonClient * _Nonnull)client
                     withAccountId:(NSString * _Nonnull)accountId
                     operationType:(MastodonClientAccountOperationType)type
                        completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client accountOperationUrlWithAccountId:accountId operationType:type]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonAccount alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeFollow
                          completion:completionBlock];
}

- (void)unfollowAccountWithClient:(MastodonClient * _Nonnull)client
                    withAccountId:(NSString * _Nonnull)accountId
                       completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeUnfollow
                          completion:completionBlock];
}

- (void)blockAccountWithClient:(MastodonClient * _Nonnull)client
                 withAccountId:(NSString * _Nonnull)accountId
                    completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeBlock
                          completion:completionBlock];
}

- (void)unblockAccountWithClient:(MastodonClient * _Nonnull)client
                   withAccountId:(NSString * _Nonnull)accountId
                      completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeUnblock
                          completion:completionBlock];
}

- (void)muteAccountWithClient:(MastodonClient * _Nonnull)client
                withAccountId:(NSString * _Nonnull)accountId
                   completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeMute
                          completion:completionBlock];
}

- (void)unmuteAccountWithClient:(MastodonClient * _Nonnull)client
                  withAccountId:(NSString * _Nonnull)accountId
                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    [self accountOperationWithClient:client
                       withAccountId:accountId
                       operationType:MastodonClientAccountOperationTypeUnmute
                          completion:completionBlock];
}

- (void)apporveFollowRequestWithClient:(MastodonClient * _Nonnull)client
                         withAccountId:(NSString * _Nonnull)accountId
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"POST"
                 onResource:client.apporveFollowRequestsUrl
            usingParameters:@{@"id": accountId}
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    completionBlock(YES, responseData, nil);
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)rejectFollowRequestWithClient:(MastodonClient * _Nonnull)client
                        withAccountId:(NSString * _Nonnull)accountId
                           completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"POST"
                 onResource:client.rejectFollowRequestsUrl
            usingParameters:@{@"id": accountId}
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    completionBlock(YES, responseData, nil);
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)followAccountWithClient:(MastodonClient * _Nonnull)client
                        withAccountUri:(NSString * _Nonnull)accountUri
                           completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"POST"
                 onResource:client.followsAccountUrl
            usingParameters:@{@"uri": accountUri}
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonAccount alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }else{
                    completionBlock(YES, responseData, nil);
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Fetching Account Information

- (void)fetchCurentUserMutesWithClient:(MastodonClient * _Nonnull)client
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.muteAccountUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchCurentUserBlocksWithClient:(MastodonClient * _Nonnull)client
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.blockedAccountUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchCurentUserStatusesWithClient:(MastodonClient * _Nonnull)client
                                    maxId:(NSString * _Nullable)maxId
                                  sinceId:(NSString * _Nullable)sinceId
                                    limit:(NSInteger)limit
                               completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.favouriteStatusesUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchCurentUserFollowRequestsWithClient:(MastodonClient * _Nonnull)client
                                          maxId:(NSString * _Nullable)maxId
                                        sinceId:(NSString * _Nullable)sinceId
                                          limit:(NSInteger)limit
                                     completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.followRequestsUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchAccountStatusesWithClient:(MastodonClient * _Nonnull)client
                             accountId:(NSString * _Nonnull)accountId
                                 maxId:(NSString * _Nullable)maxId
                               sinceId:(NSString * _Nullable)sinceId
                                 limit:(NSInteger)limit
                             onlyMedia:(BOOL)onlyMedia
                        excludeReplies:(BOOL)excludeReplies
                            completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        if (onlyMedia) {
            [param setObject:@(onlyMedia).stringValue forKey:@"only_media"];
        }
        
        if (onlyMedia) {
            [param setObject:@(excludeReplies).stringValue forKey:@"exclude_replies"];
        }
        
        [self performMethod:@"GET"
                 onResource:[client accountStatusesUrlWithAccountId:accountId]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchAccountFollowingWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:[client accountFollowingsUrlWithAccountId:accountId]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchAccountFollowersWithClient:(MastodonClient * _Nonnull)client
                              accountId:(NSString * _Nonnull)accountId
                                  maxId:(NSString * _Nullable)maxId
                                sinceId:(NSString * _Nullable)sinceId
                                  limit:(NSInteger)limit
                             completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:[client accountFollowersUrlWithAccountId:accountId]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonAccount alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchCurentUserAccountInfoWithClient:(MastodonClient * _Nonnull)client
                                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:client.currentUserUrl
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonAccount alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchAccountInfoWithClient:(MastodonClient * _Nonnull)client
                         accountId:(NSString * _Nonnull)accountId
                        completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        [self performMethod:@"GET"
                 onResource:[client accountUrlWithAccountId:accountId]
            usingParameters:nil
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                            completionBlock(YES, [[MastodonAccount alloc] initWithDictionary:jsonObject], nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Fetching Timeline

- (void)fetchTagsTimelineWithClient:(MastodonClient * _Nonnull)client
                                tag:(NSString * _Nonnull)tag
                            isLocal:(BOOL)isLocal
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [param setObject:@(isLocal).stringValue forKey:@"local"];
        
        [self performMethod:@"GET"
                 onResource:[client timelineWithTag:tag]
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchPublicTimelineWithClient:(MastodonClient * _Nonnull)client
                                maxId:(NSString * _Nullable)maxId
                              sinceId:(NSString * _Nullable)sinceId
                                limit:(NSInteger)limit
                           completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [self performMethod:@"GET"
                 onResource:client.publicTimelineUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchHomeTimelineWithClient:(MastodonClient * _Nonnull)client
                              maxId:(NSString * _Nullable)maxId
                            sinceId:(NSString * _Nullable)sinceId
                              limit:(NSInteger)limit
                         completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    // TODO: Select Account?
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        
        [param setObject:@(NO).stringValue forKey:@"local"];
        
        [self performMethod:@"GET"
                 onResource:client.homeTimelineUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
}

- (void)fetchLocalTimelineWithClient:(MastodonClient * _Nonnull)client
                               maxId:(NSString * _Nullable)maxId
                             sinceId:(NSString * _Nullable)sinceId
                               limit:(NSInteger)limit
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    // TODO: Select Account?
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    
    if (accounts.count != 0) {
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        
        if (maxId != nil) {
            [param setObject:maxId forKey:@"max_id"];
        }
        
        if (sinceId != nil) {
            [param setObject:sinceId forKey:@"since_id"];
        }
        
        if (limit != 0) {
            [param setObject:@(limit) forKey:@"limit"];
        }
        
        [param setObject:@(YES).stringValue forKey:@"local"];
        
        [self performMethod:@"GET"
                 onResource:client.publicTimelineUrl
            usingParameters:param
                withAccount:accounts[0]
                 withClient:client
        sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
            // e.g., update a progress indicator
        }
            responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                // Process the response
                if (error != nil) {
                    completionBlock(NO, nil, error);
                }else{
                    NSError *jsonError;
                    id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                    
                    if (jsonError != nil) {
                        completionBlock(NO, nil, jsonError);
                    }else{
                        if ([jsonObject isKindOfClass:[NSArray class]]) {
                            NSArray *arr = (NSArray *)jsonObject;
                            NSMutableArray *result = [[NSMutableArray alloc] init];
                            for (NSDictionary *info in arr) {
                                [result addObject:[[MastodonStatus alloc] initWithDictionary:info]];
                            }
                            completionBlock(YES, result, nil);
                        }else{
                            completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                        }
                    }
                }
            }];
    }else{
        completionBlock(NO, nil, nil);
    }
    
}

#pragma mark - Upload Media

- (void)uploadFileWithClient:(MastodonClient * _Nonnull)client
                    fileData:(NSData * _Nonnull)fileData
                    progress:(MastodonClientRequestProgessBlock _Nullable)progressBlock
                  completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    NSArray <MastodonClient *> *clients = self.clientsList;
    
    if ([clients containsObject:client]) {
        client = [clients objectAtIndex:[clients indexOfObject:client]];
    }
    
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    if (accounts.count != 0) {
        
        if (fileData != nil) {
            [self performMethod:@"POST"
                     onResource:client.mediaAttachmentUrl
                usingParameters:@{@"file": fileData}
                    withAccount:accounts[0]
                     withClient:client
            sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                // e.g., update a progress indicator
                
                progressBlock((double)bytesSend / (double)bytesTotal);
            }
                responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                    // Process the response
                    if (error != nil) {
                        completionBlock(NO, nil, error);
                    }else{
                        NSError *jsonError;
                        id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                        
                        if (jsonError != nil) {
                            completionBlock(NO, nil, jsonError);
                        }else{
                            if ([jsonObject isKindOfClass:[NSDictionary class]]) {
                                completionBlock(YES, [[MastodonAttachment alloc] initWithDictionary:jsonObject], nil);
                            }else{
                                completionBlock(NO, nil, [NSError serverErrorWithResponse:jsonObject]);
                            }
                        }
                    }
                }];
        }else{
            completionBlock(NO, nil, nil);
        }
        
        
    }else{
        completionBlock(NO, nil, nil);
    }
}

#pragma mark - Setter & Getter

#if TARGET_OS_IOS
- (NSArray <MastodonClient *> *)clientsList{
    return [NSUserDefaults clientsArrayWithApplicationName:self.applicationName];
}

- (void)setClientsList:(NSArray<MastodonClient *> *)clientsList{
    [NSUserDefaults setClientsArray:clientsList applicationName:self.applicationName];
}
#endif

- (void)updateClient:(MastodonClient *)client{
    NSMutableArray *clients = [[NSMutableArray alloc] initWithArray:self.clientsList];
    
    if ([clients containsObject:client]) {
        [clients replaceObjectAtIndex:[clients indexOfObject:client] withObject:client];
        
        self.clientsList = [NSArray arrayWithArray:clients];
    }
}

- (MastodonClient * _Nullable)getClientWithInstanceUrl:(NSURL * _Nonnull)instanceUrl{
    NSArray <MastodonClient *> *clients = self.clientsList;
    for (MastodonClient *client in clients) {
        if ([client.instanceUrl.absoluteString isEqualToString:instanceUrl.absoluteString]) {
            return client;
        }
    }
    return nil;
}

#pragma mark - Helper

- (NSDictionary *)urlEncodeArray:(NSArray *)array
                         withKey:(NSString *)key{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    NSInteger idx = 0;
    for (id obj in array) {
        [result setObject:obj forKey:[NSString stringWithFormat:@"%@[%li]", key, (long)idx]];
        idx++;
    }
    return [NSDictionary dictionaryWithDictionary:result];
}

- (void)performMethod:(NSString *)aMethod
           onResource:(NSURL *)aResource
      usingParameters:(NSDictionary *)someParameters
          withAccount:(NXOAuth2Account *)anAccount
           withClient:(MastodonClient * _Nonnull)client
  sendProgressHandler:(NXOAuth2ConnectionSendingProgressHandler)progressHandler
      responseHandler:(NXOAuth2ConnectionResponseHandler)responseHandler{
    __weak typeof(self) weakSelf = self;
    
    [[NSUserDefaults standardUserDefaults] setValue:client.instanceUrl.absoluteString forKey:MastodonKitLastUsedClientKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NXOAuth2Request performMethod:aMethod
                        onResource:aResource
                   usingParameters:someParameters
                       withAccount:anAccount
               sendProgressHandler:progressHandler
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                       // Process the response
                       if (error != nil) {
                           if ([error.domain isEqualToString:NXOAuth2HTTPErrorDomain] && error.code == 401) {
                               // Unauthorized
                               [[NXOAuth2AccountStore sharedStore] removeAccount:anAccount];
                               
                               client.isAuthorized = NO;
                               [weakSelf updateClient:client];
                               
                               responseHandler(response, responseData, [NSError unauthorizedError]);
                           }else{
                               responseHandler(response, responseData, error);
                           }
                           
                       }else{
                           responseHandler(response, responseData, error);
                       }
                   }];
}

- (NSString *)stringOrNilForObject:(id)object{
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }else{
        if ([object respondsToSelector:@selector(stringValue)]) {
            return [object stringValue];
        }else{
            return object;
        }
    }
}

- (NSData *)httpBodyForParameters:(NSDictionary *)parameters {
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        NSString *value = [weakSelf stringOrNilForObject:obj];
        
        if (value.length != 0 && key.length != 0) {
            NSString *param = [NSString stringWithFormat:@"%@=%@", [weakSelf percentEscapeString:key], [weakSelf percentEscapeString:value]];
            [parameterArray addObject:param];
        }
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)percentEscapeString:(NSString *)string {
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}

@end
