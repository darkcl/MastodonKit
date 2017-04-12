//
//  MastodonClient.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 6/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonClient.h"

#import "MastodonConstants.h"

static NSString *const kInstanceUrlKey = @"instance_url";
static NSString *const kAppIdKey = @"app_id";
static NSString *const kRedirectUriKey = @"redirect_uri";
static NSString *const kClientIdKey = @"client_id";
static NSString *const kClientSecretKey = @"client_secret";

@interface MastodonClient() {
    
}

@end

@implementation MastodonClient

- (instancetype)initWithInstanceURL:(NSURL *)url{
    if (self = [super init]) {
        _instanceUrl = url;
    }
    return self;
}

+ (instancetype)clientWithInstanceURL:(NSURL *)url{
    return [[self alloc] initWithInstanceURL:url];
}

- (NSURL *)registerAppUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/apps", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)authUrl{
    NSString *result = [NSString stringWithFormat:@"%@/oauth/authorize?response_type=code", self.instanceUrl.absoluteString];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)tokenUrl{
    NSString *result = [NSString stringWithFormat:@"%@/oauth/token", self.instanceUrl.absoluteString];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)timelineWithTag:(NSString * _Nonnull)tag{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/timelines/tag/%@", self.instanceUrl.absoluteString, MastodonAPIVersion, tag];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)homeTimelineUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/timelines/home", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)publicTimelineUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/timelines/public", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)currentUserUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/verify_credentials", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL *)accountUrlWithAccountId:(NSString *)accountId{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/%@", self.instanceUrl.absoluteString, MastodonAPIVersion, accountId];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)accountFollowersUrlWithAccountId:(NSString * _Nonnull)accountId{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/%@/followers", self.instanceUrl.absoluteString, MastodonAPIVersion, accountId];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)accountFollowingsUrlWithAccountId:(NSString * _Nonnull)accountId{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/%@/following", self.instanceUrl.absoluteString, MastodonAPIVersion, accountId];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)accountStatusesUrlWithAccountId:(NSString * _Nonnull)accountId{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/%@/statuses", self.instanceUrl.absoluteString, MastodonAPIVersion, accountId];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)accountOperationUrlWithAccountId:(NSString * _Nonnull)accountId
                                       operationType:(MastodonClientAccountOperationType)type{
    NSString *typeStr = @"";
    
    switch (type) {
        case MastodonClientAccountOperationTypeFollow:
            typeStr = @"follow";
            break;
        case MastodonClientAccountOperationTypeUnfollow:
            typeStr = @"unfollow";
            break;
        case MastodonClientAccountOperationTypeBlock:
            typeStr = @"block";
            break;
        case MastodonClientAccountOperationTypeUnblock:
            typeStr = @"unblock";
            break;
        case MastodonClientAccountOperationTypeMute:
            typeStr = @"mute";
            break;
        case MastodonClientAccountOperationTypeUnmute:
            typeStr = @"unmute";
            break;
        default:
            break;
    }
    
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/accounts/%@/%@", self.instanceUrl.absoluteString, MastodonAPIVersion, accountId, typeStr];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)accountRelationshipUrlWithAccountIds:(NSArray <NSString *> * _Nonnull)accountIds{
    NSURLComponents *comp = [[NSURLComponents alloc] init];
    comp.scheme = self.instanceUrl.scheme;
    comp.host = self.instanceUrl.host;
    comp.path = [NSString stringWithFormat:@"/api/%@/accounts/relationships", MastodonAPIVersion];
    
    NSMutableArray *queries = [[NSMutableArray alloc] init];
    
    for (NSString *accountId in accountIds) {
        [queries addObject:[[NSURLQueryItem alloc] initWithName:@"id[]" value:accountId]];
    }
    
    comp.queryItems = queries;
    return comp.URL;
}

- (NSURL * _Nonnull)blockedAccountUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/blocks", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)favouriteStatusesUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/favourites", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)followRequestsUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/follow_requests", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)apporveFollowRequestsUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/follow_requests/authorize", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)rejectFollowRequestsUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/follow_requests/reject", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)followsAccountUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/follows", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (NSURL * _Nonnull)mediaAttachmentUrl{
    NSString *result = [NSString stringWithFormat:@"%@/api/%@/media", self.instanceUrl.absoluteString, MastodonAPIVersion];
    
    return [NSURL URLWithString:result];
}

- (BOOL)isEqual:(id)object{
    if ([object isKindOfClass:[MastodonClient class]]) {
        MastodonClient *client = (MastodonClient *)object;
        
        return [client.instanceUrl.absoluteString isEqualToString:self.instanceUrl.absoluteString];
        
    }else{
        return NO;
    }
}

- (BOOL)isRegistered{
    if (self.appId != nil && self.clientId !=nil && self.clientSecret != nil && self.redirectUri != nil) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.instanceUrl = [aDecoder decodeObjectForKey:kInstanceUrlKey];
        self.appId = [aDecoder decodeObjectForKey:kAppIdKey];
        self.redirectUri = [aDecoder decodeObjectForKey:kRedirectUriKey];
        self.clientId = [aDecoder decodeObjectForKey:kClientIdKey];
        self.clientSecret = [aDecoder decodeObjectForKey:kClientSecretKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.instanceUrl forKey:kInstanceUrlKey];
    [aCoder encodeObject:self.appId forKey:kAppIdKey];
    [aCoder encodeObject:self.redirectUri forKey:kRedirectUriKey];
    [aCoder encodeObject:self.clientId forKey:kClientIdKey];
    [aCoder encodeObject:self.clientSecret forKey:kClientSecretKey];
}

@end
