//
//  MastodonTags.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonTags.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonTags

- (NSString *)name{
    return [self.infoDict stringOrNilForKey:@"name"];
}

- (NSURL *)url{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"url"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
