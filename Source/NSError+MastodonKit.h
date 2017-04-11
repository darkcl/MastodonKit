//
//  NSError+MastodonKit.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (MastodonKit)

+ (NSError *)loginCancelError;

+ (NSError *)serverErrorWithResponse:(NSDictionary *)response;

@end
