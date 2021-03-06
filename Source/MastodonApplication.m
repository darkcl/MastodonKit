//
//  MastodonApplication.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonApplication.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonApplication

- (NSString *)name{
    return [self.infoDict stringOrNilForKey:@"name"];
}

- (NSURL *)website{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"website"];
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
