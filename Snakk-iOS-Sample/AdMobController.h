//
//  AdMobController.h
//  Snakk-iOS-Sample
//
//
//

#import <Foundation/Foundation.h>
#import "GADBannerViewDelegate.h"
#import "GADInterstitialDelegate.h"

enum {
    StateNone       = 0,
    StateLoading    = 1,
    StateError      = 2,
    StateReady      = 3,
};
typedef NSUInteger ButtonState;

@class GADBannerView, GADInterstitial;

@interface AdMobController : UIViewController <GADBannerViewDelegate, GADInterstitialDelegate> {
    GADBannerView *bannerView_;
    GADInterstitial *interstitial_;
}

@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (retain, nonatomic) IBOutlet UIButton *loadButton;
@property (retain, nonatomic) IBOutlet UIButton *showButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end
