//
//  SnakkBannerAd.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SnakkConstants.h"
#import "SnakkAdDelegates.h"

@class SnakkRequest;

@interface SnakkBannerAdView : UIView

@property (assign, nonatomic) id<SnakkBannerAdViewDelegate> delegate;
@property (assign, nonatomic) BOOL animated;
@property (assign, nonatomic) BOOL autoReposition;
@property (assign, nonatomic) BOOL showLoadingOverlay;
@property (assign, nonatomic) BOOL shouldReloadAfterTap DEPRECATED_ATTRIBUTE;
@property (readonly) BOOL isServingAds;
@property (assign) SnakkBannerHideDirection hideDirection;
@property (assign, nonatomic) UIViewController *presentingController;
@property NSUInteger locationPrecision;

- (BOOL)startServingAdsForRequest:(SnakkRequest *)request;
- (void)updateLocation:(CLLocation *)location;
- (void)hide;
- (void)cancelAds;

- (void)pause;
- (void)resume;

- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
