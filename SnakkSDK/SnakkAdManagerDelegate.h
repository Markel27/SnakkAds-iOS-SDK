//
//  SnakkAdManagerDelegate.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnakkPrivateConstants.h"

@class SnakkAdView, SnakkRequest;

@protocol SnakkAdManagerDelegate <NSObject>
@required
- (void)willLoadAdWithRequest:(SnakkRequest *)request;
- (void)didLoadAdView:(SnakkAdView *)adView;
- (void)adView:(SnakkAdView *)adView didFailToReceiveAdWithError:(NSError*)error;
- (BOOL)adActionShouldBegin:(NSURL *)actionUrl willLeaveApplication:(BOOL)willLeave;
- (void)adViewActionDidFinish:(SnakkAdView *)adView;

@optional
- (void)didReceiveData:(NSDictionary *)data;

- (void)timerElapsed;
@end
