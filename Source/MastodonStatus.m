//
//  MastodonStatus.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonStatus.h"

#import "NSDictionary+MastodonKit.h"

#import "MastodonAccount.h"

#import "MastodonAttachment.h"

#import "MastodonMention.h"

#import "MastodonTags.h"

#import "MastodonApplication.h"

@implementation MastodonStatus

- (NSString *)statusId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (NSString *)uri{
    return [self.infoDict stringOrNilForKey:@"uri"];
}

- (NSURL *)url{
    NSString *str = [self.infoDict stringOrNilForKey:@"url"];
    
    if (str) {
        NSURL *result = [NSURL URLWithString:str];
        
        return result;
    }else{
        return nil;
    }
}

- (MastodonAccount *)account{
    NSDictionary *accountInfoDict = [self.infoDict objectOrNilForKey:@"account"];
    if (accountInfoDict && [accountInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonAccount alloc] initWithDictionary:accountInfoDict];
    }else{
        return nil;
    }
}

- (NSString *)inReplyToId{
    return [self.infoDict stringOrNilForKey:@"in_reply_to_id"];
}

- (NSString *)inReplyToAccountId{
    return [self.infoDict stringOrNilForKey:@"in_reply_to_account_id"];
}

- (void)setReblog:(MastodonStatus *)reblog{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithDictionary:self.infoDict];
    [result setObject:reblog.infoDict forKey:@"reblog"];
    
    self.infoDict = [NSDictionary dictionaryWithDictionary:result];
}

- (MastodonStatus *)reblog{
    NSDictionary *reblogInfoDict = [self.infoDict objectOrNilForKey:@"reblog"];
    if (reblogInfoDict && [reblogInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonStatus alloc] initWithDictionary:reblogInfoDict];
    }else{
        return nil;
    }
}

- (NSString *)content{
    return [self.infoDict stringOrNilForKey:@"content"];
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

- (NSInteger)reblogsCount{
    return [[self.infoDict stringOrNilForKey:@"reblogs_count"] integerValue];
}

- (NSInteger)favouritesCount{
    return [[self.infoDict stringOrNilForKey:@"favourites_count"] integerValue];
}

- (void)setReblogged:(BOOL)reblogged{
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] initWithDictionary:self.infoDict];
    
    [aDict setValue:@(reblogged) forKey:@"reblogged"];
    
    self.infoDict = [NSDictionary dictionaryWithDictionary:aDict];
}

- (BOOL)reblogged{
    return [[self.infoDict stringOrNilForKey:@"reblogged"] boolValue];
}

- (void)setFavourited:(BOOL)favourited{
    NSMutableDictionary *aDict = [[NSMutableDictionary alloc] initWithDictionary:self.infoDict];
    
    [aDict setValue:@(favourited) forKey:@"favourited"];
    
    self.infoDict = [NSDictionary dictionaryWithDictionary:aDict];
}

- (BOOL)favourited{
    return [[self.infoDict stringOrNilForKey:@"favourited"] boolValue];
}

- (BOOL)sensitive{
    return [[self.infoDict stringOrNilForKey:@"sensitive"] boolValue];
}

- (NSString *)spoilerText{
    return [self.infoDict stringOrNilForKey:@"spoiler_text"];
}

- (MastodonStatusVisibility)visibility{
    NSString *str = [self.infoDict stringOrNilForKey:@"visibility"];
    
    if ([str isEqualToString:@"public"]) {
        return MastodonStatusVisibilityPublic;
    }else if ([str isEqualToString:@"unlisted"]) {
        return MastodonStatusVisibilityUnlisted;
    }else if ([str isEqualToString:@"private"]) {
        return MastodonStatusVisibilityPrivate;
    }else if ([str isEqualToString:@"direct"]) {
        return MastodonStatusVisibilityDirect;
    }else{
        return MastodonStatusVisibilityUnknow;
    }
}

- (NSArray <MastodonAttachment *> *)mediaAttachments{
    NSArray *arr = [self.infoDict objectOrNilForKey:@"media_attachments"];
    
    if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in arr) {
            [result addObject:[[MastodonAttachment alloc] initWithDictionary:dict]];
        }
        return [NSArray arrayWithArray:result];
    }else{
        return nil;
    }
}

- (NSArray <MastodonMention *> *)mentions{
    NSArray *arr = [self.infoDict objectOrNilForKey:@"mentions"];
    
    if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in arr) {
            [result addObject:[[MastodonMention alloc] initWithDictionary:dict]];
        }
        return [NSArray arrayWithArray:result];
    }else{
        return nil;
    }
}

- (NSArray <MastodonTags *> *)tags{
    NSArray *arr = [self.infoDict objectOrNilForKey:@"tags"];
    
    if (arr != nil && [arr isKindOfClass:[NSArray class]]) {
        NSMutableArray *result = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in arr) {
            [result addObject:[[MastodonTags alloc] initWithDictionary:dict]];
        }
        return [NSArray arrayWithArray:result];
    }else{
        return nil;
    }
}

- (MastodonApplication *)application{
    NSDictionary *appInfoDict = [self.infoDict objectOrNilForKey:@"application"];
    if (appInfoDict && [appInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonApplication alloc] initWithDictionary:appInfoDict];
    }else{
        return nil;
    }
}

@end
