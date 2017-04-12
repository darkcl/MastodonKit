//
//  MastodonClientManagerBuilder.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClientManagerBuilder.h"

#import "MastodonClientManager.h"

@implementation MastodonClientManagerBuilder

- (nonnull MastodonClientManager *)build{
    MastodonClientManager *manager = [[MastodonClientManager alloc] init];
    
    if (self.applicationName != nil && self.applicationName.length != 0) {
        manager.applicationName = self.applicationName;
    }else{
        manager.applicationName = @"MastodonKit";
    }
    
    if (self.redirectUri != nil && self.redirectUri.length != 0) {
        manager.redirectUri = self.redirectUri;
    }else{
        manager.redirectUri = @"urn:ietf:wg:oauth:2.0:oob";
    }
    
    if (self.scopes != nil) {
        manager.scopes = self.scopes;
    }else{
        manager.scopes = [NSSet setWithObjects:@"read", @"write", @"follow", nil];
    }
    
    manager.websiteUrl = self.websiteUrl;
    
    return manager;
}

@end
