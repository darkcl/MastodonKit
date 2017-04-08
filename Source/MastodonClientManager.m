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

#ifdef COCOAPODS
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif



#import "NSDictionary+MastodonKit.h"

@interface MastodonClientManager() {
    
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
    
    [clients addObject:client];
    
    self.clientsList = [NSArray arrayWithArray:clients];
    
    return client;
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
            NSLog(@"dataTaskWithRequest error: %@", error);
            
            completionBlock(NO, error);
        }else{
            NSError *parseError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
            if (!responseObject) {
                NSLog(@"JSON parse error: %@", parseError);
                completionBlock(NO, parseError);
            } else {
                NSLog(@"responseObject = %@", responseObject);
                
                NSString *appId = [responseObject stringOrNilForKey:@"id"];
                NSString *redirectUri = [responseObject stringOrNilForKey:@"redirect_uri"];
                NSString *clientId = [responseObject stringOrNilForKey:@"client_id"];
                NSString *clientSecret = [responseObject stringOrNilForKey:@"client_secret"];
                
                client.appId = appId;
                
                [[NXOAuth2AccountStore sharedStore] setClientID:clientId
                                                         secret:clientSecret
                                               authorizationURL:client.authUrl
                                                       tokenURL:client.tokenUrl
                                                    redirectURL:[NSURL URLWithString:redirectUri]
                                                 forAccountType:[NSString stringWithFormat:@"%@@%@", weakSelf.applicationName, client.instanceUrl.host]];
                
                completionBlock(YES, nil);
            }
        }
        
    }];
    [task resume];
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
