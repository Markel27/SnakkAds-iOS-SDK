//
//  FirstViewController.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SnakkAdDelegates.h"

@class SnakkBannerAdView;

@interface BannerAdController : UIViewController <SnakkBannerAdViewDelegate>

@property (retain, nonatomic) IBOutlet SnakkBannerAdView *snakkAd;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
