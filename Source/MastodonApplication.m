//
//  MastodonApplication.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonApplication.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonApplication() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonApplication

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)name{
    return [_infoDict stringOrNilForKey:@"name"];
}

- (NSURL *)website{
    NSString *urlString = [_infoDict stringOrNilForKey:@"website"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
