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

#import "NSError+MastodonKit.h"

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
    
    return [managerBuilder build];
}

- (MastodonClient * _Nonnull)createClient:(NSURL * _Nullable)instanceUrl{
    MastodonClient *client;
    
    if (instanceUrl != nil) {
        client = [MastodonClient clientWithInstanceURL:instanceUrl];
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
                
                if (redirectUri != nil &&
                    clientId != nil &&
                    clientSecret != nil) {
                    [[NXOAuth2AccountStore sharedStore] setClientID:clientId
                                                             secret:clientSecret
                                                   authorizationURL:client.authUrl
                                                           tokenURL:client.tokenUrl
                                                        redirectURL:[NSURL URLWithString:redirectUri]
                                                     forAccountType:[weakSelf serviceNameWithClient:client]];
                    
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

- (void)fetchLocalTimelineWithClient:(MastodonClient * _Nonnull)client
                          completion:(MastodonClientRequestComplationBlock _Nullable)completionBlock{
    
    [[NXOAuth2AccountStore sharedStore] setClientID:client.clientId
                                             secret:client.clientSecret
                                   authorizationURL:client.authUrl
                                           tokenURL:client.tokenUrl
                                        redirectURL:[NSURL URLWithString:self.redirectUri]
                                     forAccountType:[self serviceNameWithClient:client]];
    
    // TODO: Select Account?
    NSArray <NXOAuth2Account *> *accounts = [[NXOAuth2AccountStore sharedStore] accountsWithAccountType:[self serviceNameWithClient:client]];
    
    __weak typeof(self) weakSelf = self;
    
    if (accounts.count != 0) {
        
        [NXOAuth2Request performMethod:@"GET"
                            onResource:client.localTimelineUrl
                       usingParameters:nil
                           withAccount:accounts[0]
                   sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                       // e.g., update a progress indicator
                   }
                       responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error){
                           // Process the response
                           if (error != nil) {
                               if ([error.domain isEqualToString:NXOAuth2HTTPErrorDomain] && error.code == 401) {
                                   // Unauthorized
                                   [[NXOAuth2AccountStore sharedStore] removeAccount:accounts[0]];
                                   
                                   [weakSelf loginWithClient:client
                                                  completion:^(BOOL success, NSURL * _Nullable authUrl, NSError * _Nullable error) {
                                                      if (success) {
                                                          [weakSelf fetchLocalTimelineWithClient:client completion:completionBlock];
                                                      }else{
                                                          completionBlock(NO, nil, error);
                                                      }
                                                  }];
                               }
                               
                               completionBlock(NO, nil, error);
                           }else{
                               NSError *jsonError;
                               id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];
                               
                               if (jsonError != nil) {
                                   completionBlock(NO, nil, jsonError);
                               }else{
                                   completionBlock(YES, jsonObject, nil);
                               }
                           }
                       }];
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


#pragma mark - Helper



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
