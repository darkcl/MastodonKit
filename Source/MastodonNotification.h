//
//  MastodonNotification.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 12/4/2017.
//  Copyright © 2017 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MastodonAccount, MastodonStatus;

typedef NS_ENUM(NSInteger, MastodonNotificationType) {
    MastodonNotificationTypeUnknown = -1,
    MastodonNotificationTypeMention,
    MastodonNotificationTypeReblog,
    MastodonNotificationTypeFavourite,
    MastodonNotificationTypeFollow
};

@interface MastodonNotification : NSObject

- (instancetype _Nonnull)initWithDictionary:(NSDictionary *)infoDict;

@property (nonatomic, strong, readonly, nonnull) NSString *notificationId;

@property (readonly) MastodonNotificationType notificationType;

@property (nonatomic, strong, readonly, nonnull) NSDate *createAt;

@property (nonatomic, strong, readonly, nonnull) MastodonAccount *account;

@property (nonatomic, strong, readonly, nonnull) MastodonStatus *status;

@end
