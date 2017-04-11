//
//  NSError+MastodonKit.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "NSError+MastodonKit.h"

#import "MastodonConstants.h"

#import "NSDictionary+MastodonKit.h"

NSInteger const kLoginCancelErorCode = 1;

NSInteger const kServerErorCode = 2;

@implementation NSError (MastodonKit)

+ (NSError *)loginCancelError{
    return [NSError errorWithDomain:MastodonKitErrorDomain code:kLoginCancelErorCode userInfo:@{NSLocalizedDescriptionKey : @"User Cancel Login."}];
}

+ (NSError *)serverErrorWithResponse:(NSDictionary *)response{
    NSString *errString = [response stringOrNilForKey:@"error"];
    
    return [NSError errorWithDomain:MastodonKitErrorDomain code:kServerErorCode userInfo:@{NSLocalizedDescriptionKey :errString ? errString : @"Server Error."}];
}

@end
