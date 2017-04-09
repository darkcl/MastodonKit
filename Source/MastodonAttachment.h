//
//  MastodonAttachment.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MastodonAttachmentType) {
    MastodonAttachmentTypeUnknow = -1,
    MastodonAttachmentTypeImage,
    MastodonAttachmentTypeVideo,
    MastodonAttachmentTypeGifv
};

@interface MastodonAttachment : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)infoDict;

/**
 ID of the attachment
 */
@property (nonatomic, strong, readonly) NSString *attachmentId;

/**
 One of: "image", "video", "gifv"
 */
@property (readonly) MastodonAttachmentType type;

/**
 URL of the locally hosted version of the image
 */
@property (nonatomic, strong, readonly) NSURL *url;

/**
 For remote images, the remote URL of the original image
 */
@property (nonatomic, strong, readonly) NSURL *remoteUrl;

/**
 URL of the preview image
 */
@property (nonatomic, strong, readonly) NSURL *previewUrl;

/**
 Shorter URL for the image, for insertion into text (only present on local images)
 */
@property (nonatomic, strong, readonly) NSURL *textUrl;

@end
