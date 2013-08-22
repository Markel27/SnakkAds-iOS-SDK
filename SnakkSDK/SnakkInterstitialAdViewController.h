//
//  SnakkInterstitialAdViewController.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakkAdDelegates.h"
#import "SnakkBrowserController.h"

@class SnakkAdView;
@class SnakkAdBrowserController;

@interface SnakkInterstitialAdViewController : UIViewController <UIActionSheetDelegate, UIWebViewDelegate>

@property (retain, nonatomic) SnakkAdView *adView;
@property (assign, nonatomic) id<SnakkInterstitialAdDelegate> snakkDelegate;
@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) BOOL autoReposition;
@property (retain, nonatomic) UIButton *closeButton;
@property (retain, nonatomic) NSURL *tappedURL;

//- (void)openURLInFullscreenBrowser:(NSURL *)url;

- (void)showLoading;
- (void)hideLoading;

- (void)showCloseButton;
- (void)hideCloseButton;

@end
