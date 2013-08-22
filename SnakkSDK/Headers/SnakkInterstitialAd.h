//
//  SnakkInterstitialAd.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnakkAdDelegates.h"
#import "SnakkConstants.h"

@class SnakkRequest;

@interface SnakkInterstitialAd : NSObject <SnakkInterstitialAdDelegate, SnakkBrowserControllerDelegate>

@property (assign, nonatomic) id<SnakkInterstitialAdDelegate> delegate;

@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) BOOL autoReposition;
@property (assign, nonatomic) BOOL showLoadingOverlay;
//@property (assign, nonatomic) SnakkInterstitialControlType controlType;
@property (assign, nonatomic) SnakkAdType allowedAdTypes;
@property (readonly) BOOL loaded;
@property (assign, nonatomic) UIViewController *presentingController;

- (BOOL)loadInterstitialForRequest:(SnakkRequest *)request;

- (void)presentFromViewController:(UIViewController *)contoller;
//- (void)presentInView:(UIView *)view;

@end
