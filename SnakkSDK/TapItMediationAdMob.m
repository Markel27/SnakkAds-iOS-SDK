//
//  TapItMediationAdMob.m
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Nick Penteado. All rights reserved.
//

#import "TapItMediationAdMob.h"
#import "GADAdSize.h"
#import "Snakk.h"

#define MEDIATION_STRING @"admob-1.0.1"

@implementation TapItMediationAdMob

@synthesize snakkAd, snakkInterstitial;

+ (NSString *)adapterVersion {
    return SNAKK_VERSION;
}

+ (Class<GADAdNetworkExtras>)networkExtrasClass {
    return nil;
}

- (id)initWithGADMAdNetworkConnector:(id<GADMAdNetworkConnector>)c {
    self = [super init];
    if (self != nil) {
        connector = c;
        redirectCount = 0;
    }
    return self;
}

- (void)getInterstitial {
    snakkInterstitial = [[SnakkInterstitialAd alloc] init];
    snakkInterstitial.delegate = self;
    snakkInterstitial.showLoadingOverlay = NO;
    NSString *zoneId = [connector publisherId];
    SnakkRequest *request = [SnakkRequest requestWithAdZone:zoneId];
    [request setCustomParameter:MEDIATION_STRING forKey:@"mediation"];
    [snakkInterstitial loadInterstitialForRequest:request];
}

- (void)getBannerWithSize:(GADAdSize)adSize {
    if (!GADAdSizeEqualToSize(adSize, kGADAdSizeBanner) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeFullBanner) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeLeaderboard) &&
        !GADAdSizeEqualToSize(adSize, kGADAdSizeMediumRectangle)) {
        NSString *errorDesc = [NSString stringWithFormat:
                               @"Invalid ad type %@, not going to get ad.",
                               NSStringFromGADAdSize(adSize)];
        NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   errorDesc, NSLocalizedDescriptionKey, nil];
        NSError *error = [NSError errorWithDomain:@"ad_mediation"
                                             code:1
                                         userInfo:errorInfo];
        [self snakkBannerAdView:nil didFailToReceiveAdWithError:error];
        return;
    }
    
    CGSize cgAdSize = CGSizeFromGADAdSize(adSize);
    CGRect adFrame = CGRectMake(0, 0, cgAdSize.width, cgAdSize.height);
    snakkAd = [[SnakkBannerAdView alloc] initWithFrame:adFrame];
    NSString *zoneId = [connector publisherId];
    snakkAd.presentingController = [connector viewControllerForPresentingModalView];
//    snakkAd.shouldReloadAfterTap = NO;
    snakkAd.showLoadingOverlay = NO;
    SnakkRequest *adRequest = [SnakkRequest requestWithAdZone:zoneId];
    [adRequest setCustomParameter:@"999999" forKey:SNAKK_PARAM_KEY_BANNER_ROTATE_INTERVAL]; // don't rotate banner
    [adRequest setCustomParameter:MEDIATION_STRING forKey:@"mediation"];
    snakkAd.delegate = self;
    [snakkAd startServingAdsForRequest:adRequest];
}

- (void)stopBeingDelegate {
    if(snakkInterstitial) {
        snakkInterstitial.delegate = nil;
    }
    
    if(snakkAd) {
        snakkAd.delegate = nil;
    }
}

- (BOOL)isBannerAnimationOK:(GADMBannerAnimationType)animType {
    return YES;
}

- (void)presentInterstitialFromRootViewController:(UIViewController *)rootViewController {
    [snakkInterstitial presentFromViewController:rootViewController];
}

- (void)dealloc {
    [self stopBeingDelegate];
    [snakkAd release], snakkAd = nil;
    [snakkInterstitial release], snakkInterstitial = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark SnakkBannerAdViewDelegate methods

- (void)snakkBannerAdViewWillLoadAd:(SnakkBannerAdView *)bannerView {
//    TILog(@"snakkBannerAdViewWillLoadAd:");
    // no google equivilent... NOOP
}

- (void)snakkBannerAdViewDidLoadAd:(SnakkBannerAdView *)bannerView {
//    TILog(@"snakkBannerAdViewDidLoadAd:");
    [connector adapter:self didReceiveAdView:bannerView];
}

- (void)snakkBannerAdView:(SnakkBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
//    TILog(@"snakkBannerAdView:didFailToReceiveAdWithError:");
    [connector adapter:self didFailAd:error];
}

- (BOOL)snakkBannerAdViewActionShouldBegin:(SnakkBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave {
//    TILog(@"snakkBannerAdViewActionShouldBegin:willLeaveApplication:");
    if (redirectCount++ == 0) {
        // snakkBannerAdViewActionShouldBegin:willLeaveApplication: may be called multiple times... only report one click/load...
        [connector adapter:self clickDidOccurInBanner:bannerView];
        [connector adapterWillPresentFullScreenModal:self];
    }
    if (willLeave) {
        [connector adapterWillLeaveApplication:self];
    }
    return YES;
}

- (void)snakkBannerAdViewActionWillFinish:(SnakkBannerAdView *)bannerView {
//    TILog(@"snakkBannerAdViewActionWillFinish:");
    [connector adapterWillDismissFullScreenModal:self];
}

- (void)snakkBannerAdViewActionDidFinish:(SnakkBannerAdView *)bannerView {
//    TILog(@"snakkBannerAdViewActionDidFinish:");
    [connector adapterDidDismissFullScreenModal:self];
}


#pragma mark -
#pragma mark SnakkInterstitialAdDelegate methods

- (void)snakkInterstitialAd:(SnakkInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
//    TILog(@"snakkInterstitialAd:didFailWithError:");
    [connector adapter:self didFailInterstitial:error];
}

- (void)snakkInterstitialAdDidUnload:(SnakkInterstitialAd *)interstitialAd {
    // no google equivilent... NOOP
    // see snakkInterstitialAdActionWillFinish: and snakkInterstitialAdActionDidFinish:
//    TILog(@"snakkInterstitialAdDidUnload:");
}

- (void)snakkInterstitialAdWillLoad:(SnakkInterstitialAd *)interstitialAd {
    // no google equivilent... NOOP
    // see snakkInterstitialAdDidLoad
//    TILog(@"snakkInterstitialAdWillLoad:");
}

- (void)snakkInterstitialAdDidLoad:(SnakkInterstitialAd *)interstitialAd {
//    TILog(@"snakkInterstitialAdDidLoad:");
    [connector adapter:self didReceiveInterstitial:interstitialAd];
}

- (BOOL)snakkInterstitialAdActionShouldBegin:(SnakkInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
//    TILog(@"snakkInterstitialAdActionShouldBegin:willLeaveApplication:");
    if (redirectCount++ == 0) {
        [connector adapterWillPresentInterstitial:self];
    }
    if (willLeave) {
        [connector adapterWillLeaveApplication:self];
    }
    return YES;
}

- (void)snakkInterstitialAdActionWillFinish:(SnakkInterstitialAd *)interstitialAd {
//    TILog(@"snakkInterstitialAdActionWillFinish:");
    [connector adapterWillDismissInterstitial:self];
}

- (void)snakkInterstitialAdActionDidFinish:(SnakkInterstitialAd *)interstitialAd {
//    TILog(@"snakkInterstitialAdActionDidFinish:");
    [connector adapterDidDismissInterstitial:self];
}

@end
