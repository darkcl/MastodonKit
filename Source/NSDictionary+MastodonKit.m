//
//  NSDictionary+MastodonKit.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "NSDictionary+MastodonKit.h"

@implementation NSDictionary (MastodonKit)

- (id)objectOrNilForKey:(NSString *)key{
    id obj = [self objectForKey:key];
    if (obj == nil || [obj isKindOfClass:[NSNull class]]) {
        return nil;
    }else{
        return obj;
    }
}

- (NSString *)stringOrNilForKey:(NSString *)key{
    id obj = [self objectOrNilForKey:key];
    
    if (obj == nil) {
        return nil;
    }else if ([obj respondsToSelector:@selector(stringValue)]) {
        return [obj stringValue];
    }else{
        return obj;
    }
}

@end
