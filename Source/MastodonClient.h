//
//  MastodonClient.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonClient : NSObject

+ (_Nonnull instancetype)clientWithInstanceURL:(NSURL * _Nonnull)url;

@property (nonatomic, strong, nonnull) NSURL *instanceUrl;

@end
