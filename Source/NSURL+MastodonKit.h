//
//  NSURL+MastodonKit.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 14/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (MastodonKit)

- (NSURL *)urlWithParameters:(NSDictionary *)parameters;

@end
