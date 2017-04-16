//
//  MastodonMention.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonMention.h"

#import "NSDictionary+MastodonKit.h"


@implementation MastodonMention

- (NSURL *)url{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSString *)userName{
    return [self.infoDict stringOrNilForKey:@"username"];
}

- (NSString *)acct{
    return [self.infoDict stringOrNilForKey:@"acct"];
}

- (NSString *)accountId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

@end
