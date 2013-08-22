//
//  SecondViewController.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakkAdDelegates.h"


enum {
    StateNone       = 0,
    StateLoading    = 1,
    StateError      = 2,
    StateReady      = 3,
};
typedef NSUInteger ButtonState;


@class SnakkInterstitialAd;

@interface InterstitialController : UIViewController <SnakkInterstitialAdDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIButton *loadButton;
@property (retain, nonatomic) IBOutlet UIButton *showButton;

@property (retain, nonatomic) SnakkInterstitialAd *interstitialAd;

- (IBAction)loadInterstitial:(id)sender;
- (IBAction)showInterstitial:(id)sender;


- (void)updateUIWithState:(ButtonState)state;
@end
