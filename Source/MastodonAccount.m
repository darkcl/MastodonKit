//
//  MastodonAccount.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonAccount.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonAccount

- (NSString *)accountId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (NSString *)userName{
    return [self.infoDict stringOrNilForKey:@"username"];
}

- (NSString *)acct{
    return [self.infoDict stringOrNilForKey:@"acct"];
}

- (NSString *)displayName{
    return [self.infoDict stringOrNilForKey:@"display_name"];
}

- (NSString *)note{
    return [self.infoDict stringOrNilForKey:@"note"];
}

- (NSURL *)url{
    NSString *urlStr = [self.infoDict stringOrNilForKey:@"url"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (NSURL *)avatar{
    NSString *urlStr = [self.infoDict stringOrNilForKey:@"avatar"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (NSURL *)header{
    NSString *urlStr = [self.infoDict stringOrNilForKey:@"header"];
    if (urlStr) {
        return [NSURL URLWithString:urlStr];
    }else{
        return nil;
    }
}

- (BOOL)isLocked{
    return [[self.infoDict stringOrNilForKey:@"locked"] boolValue];
}

- (NSDate *)createAt{
    NSString *dateStr = [self.infoDict stringOrNilForKey:@"created_at"];
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
    return [[self.infoDict stringOrNilForKey:@"followers_count"] integerValue];
}

- (NSInteger)followingCount{
    return [[self.infoDict stringOrNilForKey:@"following_count"] integerValue];
}

- (NSInteger)statusesCount{
    return [[self.infoDict stringOrNilForKey:@"statuses_count"] integerValue];
}

@end
