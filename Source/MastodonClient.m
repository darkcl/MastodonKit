//
//  MastodonClient.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClient.h"

#import "MastodonConstants.h"

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

@end
