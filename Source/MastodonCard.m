//
//  MastodonCard.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonCard.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonCard() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonCard

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)url{
    return [_infoDict stringOrNilForKey:@"url"];
}

- (NSString *)title{
    return [_infoDict stringOrNilForKey:@"title"];
}

- (NSString *)cardDescription{
    return [_infoDict stringOrNilForKey:@"description"];
}

- (NSString *)imageUrl{
    return [_infoDict stringOrNilForKey:@"image"];
}

@end
