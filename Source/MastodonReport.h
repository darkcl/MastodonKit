//
//  MastodonReport.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MastodonReport : NSObject

- (instancetype _Nonnull)initWithDictionary:(NSDictionary * _Nonnull)infoDict;

@property (nonatomic, strong, readonly, nonnull) NSString *reportId;

@property (nonatomic, strong, readonly, nonnull) NSString *reportAction;

@end
