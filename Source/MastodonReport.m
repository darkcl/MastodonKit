//
//  MastodonReport.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonReport.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonReport() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonReport

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)reportId{
    return [_infoDict stringOrNilForKey:@"id"];
}

- (NSString *)reportAction{
    return [_infoDict stringOrNilForKey:@"action_taken"];
}

@end
