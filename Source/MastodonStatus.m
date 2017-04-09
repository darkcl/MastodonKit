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

@interface MastodonStatus() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonStatus

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)statusId{
    return [_infoDict stringOrNilForKey:@"id"];
}

- (NSString *)uri{
    return [_infoDict stringOrNilForKey:@"uri"];
}

- (NSURL *)url{
    NSString *str = [_infoDict stringOrNilForKey:@"url"];
    
    if (str) {
        NSURL *result = [NSURL URLWithString:str];
        
        return result;
    }else{
        return nil;
    }
}

- (MastodonAccount *)account{
    NSDictionary *accountInfoDict = [_infoDict objectOrNilForKey:@"account"];
    if (accountInfoDict && [accountInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonAccount alloc] initWithDictionary:accountInfoDict];
    }else{
        return nil;
    }
}

- (NSString *)inReplyToId{
    return [_infoDict stringOrNilForKey:@"in_reply_to_id"];
}

- (NSString *)inReplyToAccountId{
    return [_infoDict stringOrNilForKey:@"in_reply_to_account_id"];
}

- (MastodonStatus *)reblog{
    NSDictionary *reblogInfoDict = [_infoDict objectOrNilForKey:@"reblog"];
    if (reblogInfoDict && [reblogInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonStatus alloc] initWithDictionary:reblogInfoDict];
    }else{
        return nil;
    }
}

- (NSString *)content{
    return [_infoDict stringOrNilForKey:@"content"];
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

- (NSInteger)reblogsCount{
    return [[_infoDict stringOrNilForKey:@"reblogs_count"] integerValue];
}

- (NSInteger)favouritesCount{
    return [[_infoDict stringOrNilForKey:@"favourites_count"] integerValue];
}

- (BOOL)reblogged{
    return [[_infoDict stringOrNilForKey:@"reblogged"] boolValue];
}

- (BOOL)favourited{
    return [[_infoDict stringOrNilForKey:@"favourited"] boolValue];
}

- (BOOL)sensitive{
    return [[_infoDict stringOrNilForKey:@"sensitive"] boolValue];
}

- (NSString *)spoilerText{
    return [_infoDict stringOrNilForKey:@"spoiler_text"];
}

- (MastodonStatusVisibility)visibility{
    NSString *str = [_infoDict stringOrNilForKey:@"visibility"];
    
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
    NSArray *arr = [_infoDict objectOrNilForKey:@"media_attachments"];
    
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
    NSArray *arr = [_infoDict objectOrNilForKey:@"mentions"];
    
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
    NSArray *arr = [_infoDict objectOrNilForKey:@"tags"];
    
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
    NSDictionary *appInfoDict = [_infoDict objectOrNilForKey:@"application"];
    if (appInfoDict && [appInfoDict isKindOfClass:[NSDictionary class]]) {
        return [[MastodonApplication alloc] initWithDictionary:appInfoDict];
    }else{
        return nil;
    }
}

@end
