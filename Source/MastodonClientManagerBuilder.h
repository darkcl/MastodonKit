//
//  MastodonClientManagerBuilder.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonClientManager;

@interface MastodonClientManagerBuilder : NSObject

@property (nonatomic, strong, nullable) NSString *applicationName;

@property (nonatomic, strong, nullable) NSString *redirectUri;

@property (nonatomic, strong, nullable) NSSet <NSString *> *scopes;

@property (nonatomic, strong, nullable) NSString *websiteUrl;

- (nonnull MastodonClientManager *)build;

@end
