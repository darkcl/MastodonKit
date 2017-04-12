//
//  MastodonCard.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonCard : NSObject

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)infoDict;

@property (nonatomic, strong, readonly, nonnull) NSString *url;

@property (nonatomic, strong, readonly, nonnull) NSString *title;

@property (nonatomic, strong, readonly, nonnull) NSString *cardDescription;

@property (nonatomic, strong, readonly, nullable) NSString *imageUrl;

@end
