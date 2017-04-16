//
//  MastodonReport.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonReport.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonReport

- (NSString *)reportId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (NSString *)reportAction{
    return [self.infoDict stringOrNilForKey:@"action_taken"];
}

@end
