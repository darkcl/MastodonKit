//
//  MastodonAttachment.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonAttachment.h"

#import "NSDictionary+MastodonKit.h"

@implementation MastodonAttachment

- (NSString *)attachmentId{
    return [self.infoDict stringOrNilForKey:@"id"];
}

- (MastodonAttachmentType)type{
    NSString *typeStr = [self.infoDict stringOrNilForKey:@"type"];
    
    if ([typeStr isEqualToString:@"image"]) {
        return MastodonAttachmentTypeImage;
    }else if ([typeStr isEqualToString:@"video"]) {
        return MastodonAttachmentTypeVideo;
    }else if ([typeStr isEqualToString:@"gifv"]) {
        return MastodonAttachmentTypeGifv;
    }else{
        return MastodonAttachmentTypeUnknow;
    }
}

- (NSURL *)url{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)remoteUrl{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"remote_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)previewUrl{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"preview_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)textUrl{
    NSString *urlString = [self.infoDict stringOrNilForKey:@"text_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
