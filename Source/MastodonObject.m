//
//  MastodonObject.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 16/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonObject.h"

@implementation MastodonObject

- (instancetype)initWithDictionary:(NSDictionary * _Nonnull)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        _infoDict = [aDecoder decodeObjectForKey:@"info_dict"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_infoDict forKey:@"info_dict"];
}

- (instancetype)copyWithZone:(NSZone *)zone{
    MastodonObject *copy = [[MastodonObject alloc] initWithDictionary:self.infoDict];
    return copy;
}

@end
