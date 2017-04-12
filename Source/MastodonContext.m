//
//  MastodonContext.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonContext.h"

#import "MastodonStatus.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonContext() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonContext

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSArray <MastodonStatus *> *)ancestors{
    id obj = [_infoDict objectForKey:@"ancestors"];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        NSArray *arr = (NSArray *)obj;
        
        for (NSDictionary *infoDict in arr) {
            [result addObject:[[MastodonStatus alloc] initWithDictionary:infoDict]];
        }
        
        return [NSArray arrayWithArray:result];
    }else{
        return @[];
    }
}

- (NSArray <MastodonStatus *> *)descendants{
    id obj = [_infoDict objectForKey:@"descendants"];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        NSArray *arr = (NSArray *)obj;
        
        for (NSDictionary *infoDict in arr) {
            [result addObject:[[MastodonStatus alloc] initWithDictionary:infoDict]];
        }
        
        return [NSArray arrayWithArray:result];
    }else{
        return @[];
    }
}

@end
