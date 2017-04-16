//
//  MastodonRelationship.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 11/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonRelationship.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonRelationship

- (BOOL)isFollowing{
    return [[self.infoDict stringOrNilForKey:@"following"] boolValue];
}

- (BOOL)isFollowedBy{
    return [[self.infoDict stringOrNilForKey:@"followed_by"] boolValue];
}

- (BOOL)isBlocking{
    return [[self.infoDict stringOrNilForKey:@"blocking"] boolValue];
}

- (BOOL)isMuting{
    return [[self.infoDict stringOrNilForKey:@"muting"] boolValue];
}

- (BOOL)isRequested{
    return [[self.infoDict stringOrNilForKey:@"requested"] boolValue];
}

- (NSString *)accountId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[MastodonRelationship class]]) {
        MastodonRelationship *otherRelation = (MastodonRelationship *)object;
        return [self.accountId isEqualToString:otherRelation.accountId];
    }else{
        return NO;
    }
}

@end
