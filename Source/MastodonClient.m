//
//  MastodonClient.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClient.h"

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

@end
