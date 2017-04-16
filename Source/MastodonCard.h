//
//  MastodonCard.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@interface MastodonCard : MastodonObject

@property (nonatomic, strong, readonly, nonnull) NSString *url;

@property (nonatomic, strong, readonly, nonnull) NSString *title;

@property (nonatomic, strong, readonly, nonnull) NSString *cardDescription;

@property (nonatomic, strong, readonly, nullable) NSString *imageUrl;

@end
