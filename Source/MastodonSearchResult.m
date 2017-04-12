//
//  MastodonSearchResult.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonSearchResult.h"

#import "MastodonAccount.h"

#import "MastodonStatus.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonSearchResult() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonSearchResult

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSArray <MastodonAccount *> *)accounts{
    id obj = [_infoDict objectForKey:@"accounts"];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        NSArray *arr = (NSArray *)obj;
        
        for (NSDictionary *infoDict in arr) {
            [result addObject:[[MastodonAccount alloc] initWithDictionary:infoDict]];
        }
        
        return [NSArray arrayWithArray:result];
    }else{
        return @[];
    }
}

- (NSArray <MastodonStatus *> *)statuses{
    id obj = [_infoDict objectForKey:@"statuses"];
    
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

- (NSArray <NSString *> *)hashTags{
    id obj = [_infoDict objectForKey:@"hashtags"];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }else{
        return @[];
    }
}

@end
