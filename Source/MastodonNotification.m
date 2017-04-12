//
//  MastodonNotification.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonNotification.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonNotification() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonNotification

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

@end
