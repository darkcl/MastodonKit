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

@implementation MastodonContext

- (NSArray <MastodonStatus *> *)ancestors{
    id obj = [self.infoDict objectForKey:@"ancestors"];
    
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
    id obj = [self.infoDict objectForKey:@"descendants"];
    
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
