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

@interface MastodonClientManager() {
    
}

@end

@implementation MastodonClientManager

- (instancetype)initWithBlock:(MastodonClientManagerBuildBlock)buildBlock{
    MastodonClientManagerBuilder *managerBuilder = [[MastodonClientManagerBuilder alloc] init];
    buildBlock(managerBuilder);
    
    return [managerBuilder build];
}

- (nonnull MastodonClient *)createClient:(nullable NSURL *)instanceUrl{
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

@end
