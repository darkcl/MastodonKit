//
//  NSDictionary+MastodonKit.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "NSDictionary+MastodonKit.h"

@implementation NSDictionary (MastodonKit)

- (NSString *)stringOrNilForKey:(NSString *)key{
    id obj = [self objectForKey:key];
    
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return nil;
    }else if ([obj respondsToSelector:@selector(stringValue)]) {
        return [obj stringValue];
    }else{
        return obj;
    }
}

@end
