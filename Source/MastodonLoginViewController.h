//
//  MastodonLoginViewController.h
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MastodonLoginViewController : UIViewController

+ (void)showLoginViewWithUrl:(NSURL *)url withRedirectUri:(NSURL *)redirectUri;

@end
