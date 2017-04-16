//
//  MastodonObject.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 16/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonObject : NSObject <NSCoding, NSCopying>

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)infoDict;

@property (nonatomic, strong, nonnull) NSDictionary *infoDict;

@end
