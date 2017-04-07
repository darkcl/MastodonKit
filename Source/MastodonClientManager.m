//
//  MastodonClientManager.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 7/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClientManager.h"

#import "MastodonClientManagerBuilder.h"

@interface MastodonClientManager() {
    
}

@end

@implementation MastodonClientManager

+ (instancetype)createManagerWithBuilder:(MastodonClientManagerBuildBlock)buildBlock{
    MastodonClientManagerBuilder *managerBuilder = [[MastodonClientManagerBuilder alloc] init];
    buildBlock(managerBuilder);
    return [managerBuilder build];
}

@end
