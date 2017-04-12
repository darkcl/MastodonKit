//
//  MastodonAttachment.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 9/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonAttachment.h"

#import "NSDictionary+MastodonKit.h"

@interface MastodonAttachment() {
    NSDictionary *_infoDict;
}

@end

@implementation MastodonAttachment

- (instancetype)initWithDictionary:(NSDictionary *)infoDict{
    if (self = [super init]) {
        _infoDict = infoDict;
    }
    return self;
}

- (NSString *)attachmentId{
    return [_infoDict stringOrNilForKey:@"id"];
}

- (MastodonAttachmentType)type{
    NSString *typeStr = [_infoDict stringOrNilForKey:@"type"];
    
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
    NSString *urlString = [_infoDict stringOrNilForKey:@"url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)remoteUrl{
    NSString *urlString = [_infoDict stringOrNilForKey:@"remote_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)previewUrl{
    NSString *urlString = [_infoDict stringOrNilForKey:@"preview_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

- (NSURL *)textUrl{
    NSString *urlString = [_infoDict stringOrNilForKey:@"text_url"];
    
    if (urlString) {
        return [NSURL URLWithString:urlString];
    }else{
        return nil;
    }
}

@end
