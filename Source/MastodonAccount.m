//
//  MastodonAccount.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonAccount.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonAccount() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonAccount

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)accountId{
    return [_infoDict stringOrNilForKey:@"id"];
}

- (NSString *)userName{
    return [_infoDict stringOrNilForKey:@"username"];
}

- (NSString *)acct{
    return [_infoDict stringOrNilForKey:@"acct"];
}

- (NSString *)displayName{
    return [_infoDict stringOrNilForKey:@"display_name"];
}

- (NSString *)note{
    return [_infoDict stringOrNilForKey:@"note"];
}

- (NSURL *)url{
    NSString *urlStr = [_infoDict stringOrNilForKey:@"url"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (NSURL *)avatar{
    NSString *urlStr = [_infoDict stringOrNilForKey:@"avatar"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (NSURL *)header{
    NSString *urlStr = [_infoDict stringOrNilForKey:@"header"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (BOOL)isLocked{
    return [[_infoDict stringOrNilForKey:@"locked"] boolValue];
}

- (NSDate *)createAt{
    NSString *dateStr = [_infoDict stringOrNilForKey:@"created_at"];
    if (dateStr) {
        NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:timeZone];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        if (date) {
            NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
            NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
            
            NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:date];
            NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:date];
            NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
            
            NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:date];
            
            return destinationDate;
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

- (NSInteger)followersCount{
    return [[_infoDict stringOrNilForKey:@"followers_count"] integerValue];
}

- (NSInteger)followingCount{
    return [[_infoDict stringOrNilForKey:@"following_count"] integerValue];
}

- (NSInteger)statusesCount{
    return [[_infoDict stringOrNilForKey:@"statuses_count"] integerValue];
}

@end
