//
//  MastodonTags.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonTags.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonTags() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonTags

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)name{
    return [_infoDict stringOrNilForKey:@"name"];
}

- (NSURL *)url{
    NSString *urlString = [_infoDict stringOrNilForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
