//
//  MastodonMention.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonMention.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonMention() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonMention

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSURL *)url{
    NSString *urlString = [_infoDict stringOrNilForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSString *)userName{
    return [_infoDict stringOrNilForKey:@"username"];
}

- (NSString *)acct{
    return [_infoDict stringOrNilForKey:@"acct"];
}

- (NSString *)accountId{
    return [_infoDict stringOrNilForKey:@"id"];
}

@end
