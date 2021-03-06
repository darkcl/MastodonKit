//
//  MastodonNotification.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonNotification.h"

#import "NSDictionary+MastodonKit.h"

#import "MastodonAccount.h"

#import "MastodonStatus.h"

@implementation MastodonNotification

- (NSString *)notificationId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (MastodonNotificationType)notificationType{
    NSString *typeStr = [self.infoDict stringOrNilForKey:@"type"];
    
    if ([typeStr isEqualToString:@"mention"]) {
        return MastodonNotificationTypeMention;
    }else if ([typeStr isEqualToString:@"reblog"]){
        return MastodonNotificationTypeReblog;
    }else if ([typeStr isEqualToString:@"favourite"]){
        return MastodonNotificationTypeFavourite;
    }else if ([typeStr isEqualToString:@"follow"]){
        return MastodonNotificationTypeFollow;
    }else{
        return MastodonNotificationTypeUnknown;
    }
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

- (MastodonAccount *)account{
    id obj = [self.infoDict objectForKey:@"account"];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [[MastodonAccount alloc] initWithDictionary:obj];
    }else{
        return nil;
    }
}

- (void)setStatus:(MastodonStatus *)status{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:self.infoDict];
    [result setObject:status.infoDict forKey:@"status"];
    self.infoDict = [NSDictionary dictionaryWithDictionary:result];
}

- (MastodonStatus *)status{
    id obj = [self.infoDict objectForKey:@"status"];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        return [[MastodonStatus alloc] initWithDictionary:obj];
    }else{
        return nil;
    }
}

@end
