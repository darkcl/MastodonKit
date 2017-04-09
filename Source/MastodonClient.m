//
//  MastodonClient.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClient.h"

#import "MastodonConstants.h"

static NSString *const kInstanceUrlKey = @"instance_url";
static NSString *const kAppIdKey = @"app_id";
static NSString *const kRedirectUriKey = @"redirect_uri";
static NSString *const kClientIdKey = @"client_id";
static NSString *const kClientSecretKey = @"client_secret";

@interface MastodonClient() {
    
}

@end

@implementation MastodonClient

- (instancetype)initWithInstanceURL:(NSURL *)url{
    if (self = [super init]) {
        _instanceUrl = url;
    }
    return self;
}

+ (instancetype)clientWithInstanceURL:(NSURL *)url{
    return [[self alloc] initWithInstanceURL:url];
}

- (NSURL *)registerAppUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/apps", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)authUrl{
    NSString *result = [NSString stringWithFormat:@"%@/oauth/authorize?response_type=code", self.instanceUrl.absoluteString];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)tokenUrl{
    NSString *result = [NSString stringWithFormat:@"%@/oauth/token", self.instanceUrl.absoluteString];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)localTimelineUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/timelines/home", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[MastodonClient class]]) {
        MastodonClient *client = (MastodonClient *)object;
        
        return [client.instanceUrl.absoluteString isEqualToString:self.instanceUrl.absoluteString];
        
    }else{
        return NO;
    }
}

- (BOOL)isRegistered{
    if (self.appId != nil && self.clientId !=nil && self.clientSecret != nil && self.redirectUri != nil) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.instanceUrl = [aDecoder decodeObjectForKey:kInstanceUrlKey];
        self.appId = [aDecoder decodeObjectForKey:kAppIdKey];
        self.redirectUri = [aDecoder decodeObjectForKey:kRedirectUriKey];
        self.clientId = [aDecoder decodeObjectForKey:kClientIdKey];
        self.clientSecret = [aDecoder decodeObjectForKey:kClientSecretKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.instanceUrl forKey:kInstanceUrlKey];
}

@end
