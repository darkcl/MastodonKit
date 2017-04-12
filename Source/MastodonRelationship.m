//
//  MastodonRelationship.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 11/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonRelationship.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonRelationship() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonRelationship

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (BOOL)isFollowing{
    return [[_infoDict stringOrNilForKey:@"following"] boolValue];
}

- (BOOL)isFollowedBy{
    return [[_infoDict stringOrNilForKey:@"followed_by"] boolValue];
}

- (BOOL)isBlocking{
    return [[_infoDict stringOrNilForKey:@"blocking"] boolValue];
}

- (BOOL)isMuting{
    return [[_infoDict stringOrNilForKey:@"muting"] boolValue];
}

- (BOOL)isRequested{
    return [[_infoDict stringOrNilForKey:@"requested"] boolValue];
}

- (NSString *)accountId{
    return [_infoDict stringOrNilForKey:@"id"];
}

@end
