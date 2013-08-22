//
//  SnakkBrowserController.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#ifndef DISABLE_NEW_FEATURES
    #import <StoreKit/StoreKit.h>
#endif

#import "SnakkAdDelegates.h"

@protocol SnakkBrowserControllerDelegate;

@interface SnakkBrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>

@property (assign, nonatomic) id<SnakkBrowserControllerDelegate> delegate;
@property (readonly) NSURL *url;
@property (assign, nonatomic) UIViewController *presentingController;
@property (assign) BOOL showLoadingOverlay;

- (void)loadUrl:(NSURL *)url;
- (void)showFullscreenBrowser;
- (void)showFullscreenBrowserAnimated:(BOOL)animated;

@end
