//
//  MastodonCard.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonCard.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonCard

- (NSString *)url{
    return [self.infoDict stringOrNilForKey:@"url"];
}

- (NSString *)title{
    return [self.infoDict stringOrNilForKey:@"title"];
}

- (NSString *)cardDescription{
    return [self.infoDict stringOrNilForKey:@"description"];
}

- (NSString *)imageUrl{
    return [self.infoDict stringOrNilForKey:@"image"];
}

@end
