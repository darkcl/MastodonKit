//
//  NSUserDefaults+MastodonKit.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (MastodonKit)

+ (NSArray *)clientsArrayWithApplicationName:(NSString *)applicationName
                      withAppGroupIdentifier:(NSString *)identifier;

+ (void)setClientsArray:(NSArray *)clients
        applicationName:(NSString *)applicationName
 withAppGroupIdentifier:(NSString *)identifier;

+ (NSUserDefaults *)appGroupUserDefault:(NSString *)identifier;

@end
