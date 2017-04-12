//
//  MastodonLoginViewController.m
//  MastodonKit
//
//  Created by Yeung Yiu Hung on 8/4/2017.
//  Copyright © 2017年 Yeung Yiu Hung. All rights reserved.
//

#import "MastodonLoginViewController.h"

#ifdef COCOAPODS
#import "NXOAuth2.h"
#else
#import <OAuth2Client/NXOAuth2.h>
#endif

@interface MastodonLoginViewController () <UIWebViewDelegate> {
    UIWebView *_webView;
    NSURL *_url;
    
    NSURL *_redirectUri;
    
    MastodonLoginSuccessBlock _success;
    MastodonLoginCancelBlock _cancel;
    MastodonLoginFailureBlock _failure;
}

@end

@implementation MastodonLoginViewController

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+ (void)showLoginViewWithUrl:(NSURL *)url
             withRedirectUri:(NSURL *)redirectUri
                success:(MastodonLoginSuccessBlock)successBlock
                      cancel:(MastodonLoginCancelBlock)cancelBlock
                     failure:(MastodonLoginFailureBlock)failureBlock{
    MastodonLoginViewController *vc = [[MastodonLoginViewController alloc] initWithLoginUrl:url withRedirectUri:redirectUri success:successBlock cancel:cancelBlock failure:failureBlock ];
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [[self topMostController] presentViewController:navVC animated:YES completion:nil];
}

- (id)initWithLoginUrl:(NSURL *)loginUrl
       withRedirectUri:(NSURL *)redirectUri
               success:(MastodonLoginSuccessBlock)successBlock
                cancel:(MastodonLoginCancelBlock)cancelBlock
               failure:(MastodonLoginFailureBlock)failureBlock{
    if (self = [super init]) {
        _url = loginUrl;
        _redirectUri = redirectUri;
        
        _success = successBlock;
        _failure = failureBlock;
        _cancel = cancelBlock;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      if(_failure != nil) {
                                                          _failure(error);
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){
                                                      if(_success != nil) {
                                                          _success();
                                                      }
                                                  }];
    
    [self.view addSubview:_webView];
    
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:_webView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0],
                                
                                [NSLayoutConstraint constraintWithItem:_webView
                                                             attribute:NSLayoutAttributeLeft
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeft
                                                            multiplier:1.0
                                                              constant:0],
                                
                                [NSLayoutConstraint constraintWithItem:_webView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0],
                                
                                [NSLayoutConstraint constraintWithItem:_webView
                                                             attribute:NSLayoutAttributeRight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeRight
                                                            multiplier:1
                                                              constant:0],
                                
                                ]];
    _webView.delegate = self;
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    
    self.title = @"Login to Mastodon";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
}

- (void)dismiss:(id)sender{
    if (_cancel != nil) {
        _cancel();
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = request.URL;
    if ([_redirectUri.scheme isEqualToString:url.scheme]) {
        [[NXOAuth2AccountStore sharedStore] handleRedirectURL:url];
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    if ([webView.request.URL.absoluteString rangeOfString:_redirectUri.absoluteString options:NSCaseInsensitiveSearch].location != NSNotFound) {
        [[NXOAuth2AccountStore sharedStore] handleRedirectURL:[NSURL URLWithString:webView.request.URL.absoluteString]];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:error.localizedDescription
//                                                                   message:nil
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    __weak typeof(self) weakSelf = self;
//    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
//                                                       style:UIAlertActionStyleDefault
//                                                     handler:^(UIAlertAction *action) {
//                                                         [weakSelf dismissViewControllerAnimated:YES completion:nil];
//                                                     }];
//    [alert addAction:okAction];
//    [self presentViewController:alert animated:YES completion:nil];
}

@end
