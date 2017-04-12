//
//  MastodonLoginViewController.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MastodonLoginSuccessBlock)(void);

typedef void(^MastodonLoginCancelBlock)(void);

typedef void(^MastodonLoginFailureBlock)(NSError *error);

@interface MastodonLoginViewController : UIViewController

+ (void)showLoginViewWithUrl:(NSURL *)url
             withRedirectUri:(NSURL *)redirectUri
                     success:(MastodonLoginSuccessBlock)successBlock
                      cancel:(MastodonLoginCancelBlock)cancelBlock
                     failure:(MastodonLoginFailureBlock)failureBlock;

@end
