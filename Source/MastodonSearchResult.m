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

@implementation MastodonSearchResult

- (NSArray <MastodonAccount *> *)accounts{
    id obj = [self.infoDict objectForKey:@"accounts"];
    
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
    id obj = [self.infoDict objectForKey:@"statuses"];
    
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
    id obj = [self.infoDict objectForKey:@"hashtags"];
    
    if ([obj isKindOfClass:[NSArray class]]) {
        return obj;
    }else{
        return @[];
    }
}

@end
