//
//  MastodonApplication.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MastodonObject.h"

@interface MastodonApplication : MastodonObject

/**
 Name of the app
 */
@property (nonatomic, strong, readonly) NSString *name;


/**
 Homepage URL of the app
 */
@property (nonatomic, strong, readonly) NSURL *website;

@end
