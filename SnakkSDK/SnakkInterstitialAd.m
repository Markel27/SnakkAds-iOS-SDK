//
//  SnakkInterstitialAd.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

/**
 Responsible for loading up the appropriate type of interstitial controller...
 */

#import "SnakkInterstitialAd.h"
#import "Snakk.h"
#import "SnakkAdManager.h"
#import "SnakkBannerAdView.h"
#import "SnakkInterstitialAdViewController.h"
#import "SnakkBrowserController.h"

@interface SnakkInterstitialAdViewController ()
- (void)closeTapped:(id)sender;
@end

@interface SnakkInterstitialAd() <SnakkAdManagerDelegate, SnakkMraidDelegate> 

@property (retain, nonatomic) SnakkRequest *adRequest;
@property (retain, nonatomic) SnakkAdView *adView;
@property (retain, nonatomic) SnakkAdManager *adManager;
@property (retain, nonatomic) SnakkBannerAdView *bannerView;
@property (retain, nonatomic) UIView *presentingView;
@property (retain, nonatomic) SnakkInterstitialAdViewController *adController;
@property (retain, nonatomic) SnakkBrowserController *browserController;
@property (assign) BOOL useCustomClose;

@end

@implementation SnakkInterstitialAd {
    BOOL isLoaded;
    BOOL prevStatusBarHiddenState;
    BOOL statusBarVisibilityChanged;
}

@synthesize delegate, adRequest, adView, adManager, allowedAdTypes, bannerView, presentingView, animated, autoReposition, showLoadingOverlay, adController, browserController, presentingController, useCustomClose;

- (id)init {
    self = [super init];
    if (self) {
        self.adManager = [[[SnakkAdManager alloc] init] autorelease];
        self.adManager.delegate = self;
        self.allowedAdTypes = SnakkFullscreenAdType|SnakkOfferWallType|SnakkVideoAdType;
        self.animated = YES;
        isLoaded = NO;
        self.autoReposition = YES;
        self.showLoadingOverlay = YES;
        prevStatusBarHiddenState = NO;
        statusBarVisibilityChanged = NO;
        self.useCustomClose = NO;
    }
    return self;
}

- (BOOL)loaded {
    return isLoaded;
}

- (BOOL)loadInterstitialForRequest:(SnakkRequest *)request {
    self.adRequest = request;
    [self.adRequest setCustomParameter:SNAKK_AD_TYPE_INTERSTITIAL forKey:@"adtype"];
    NSString *orientation;
    UIInterfaceOrientation uiOrt = [[UIApplication sharedApplication] statusBarOrientation];
    if (uiOrt == UIInterfaceOrientationPortrait || uiOrt == UIInterfaceOrientationPortraitUpsideDown) {
        orientation = @"p";
    } else {
        orientation = @"l";
    }
    [self.adRequest setCustomParameter:orientation forKey:@"o"];
    [self.adManager fireAdRequest:self.adRequest];
    return YES;
}

- (void)presentFromViewController:(UIViewController *)controller {
//    adController = [[SnakkLightboxAdViewController alloc] init];
    adController = [[SnakkInterstitialAdViewController alloc] init];
    self.adController.adView = self.adView;
    self.adController.animated = self.animated;
    self.adController.autoReposition = self.autoReposition;
    self.adController.snakkDelegate = self;
    
    self.presentingController = controller;

    [controller presentModalViewController:self.adController animated:YES];
    if (self.adView.isMRAID) {
        self.adView.isVisible = YES;
        [self.adView fireMraidEvent:SNAKK_MRAID_EVENT_VIEWABLECHANGE withParams:@"[true]"];
        [self.adView syncMraidState];
        if (!self.useCustomClose) {
            [self.adController showCloseButton];
        }
    }
    else {
        [self.adController showCloseButton];
    }
}

#pragma mark -
#pragma mark SnakkAdManagerDelegate methods

- (void)willLoadAdWithRequest:(SnakkRequest *)request {
    if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdWillLoad:)]) {
        [self.delegate snakkInterstitialAdWillLoad:self];
    }
}

- (void)didLoadAdView:(SnakkAdView *)theAdView {
    self.adView = theAdView;
    isLoaded = YES;
    self.adView.mraidDelegate = self;

    if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdDidLoad:)]) {
        [self.delegate snakkInterstitialAdDidLoad:self];
    }
}

- (void)adView:(SnakkAdView *)adView didFailToReceiveAdWithError:(NSError*)error {
    [self snakkInterstitialAd:self didFailWithError:error];
}

- (BOOL)adActionShouldBegin:(NSURL *)actionUrl willLeaveApplication:(BOOL)willLeave {
    BOOL shouldLoad = YES;
    if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdActionShouldBegin:willLeaveApplication:)]) {
        shouldLoad = [self.delegate snakkInterstitialAdActionShouldBegin:self willLeaveApplication:willLeave];
    }
    
    if (shouldLoad) {
        [self openURLInFullscreenBrowser:actionUrl];
        return NO; // pass off control to the full screen browser
    }
    else {
        // app decided not to allow the click to proceed... Not sure why you'd want to do this...
        return NO;
    }
}

- (void)snakkInterstitialAdDidUnload:(SnakkInterstitialAd *)interstitialAd {
    if (self.adView) {
        self.adView = nil;
    }
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdDidUnload:)]) {
            [self.delegate snakkInterstitialAdDidUnload:self];
        }
    }
}

- (void)adViewActionDidFinish:(SnakkAdView *)adView {
    // This method should always be overridden by child class
}

- (void)snakkInterstitialAd:(SnakkInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    isLoaded = NO;
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(snakkInterstitialAd:didFailWithError:)]) {
            [self.delegate snakkInterstitialAd:self didFailWithError:error];
        }
    }
}

- (BOOL)snakkInterstitialAdActionShouldBegin:(SnakkInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdActionShouldBegin:willLeaveApplication:)]) {
            return [self.delegate snakkInterstitialAdActionShouldBegin:self willLeaveApplication:willLeave];
        }
    }
    return YES;
}

- (void)snakkInterstitialAdActionWillFinish:(SnakkInterstitialAd *)interstitialAd {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdActionWillFinish:)]) {
            [self.delegate snakkInterstitialAdActionWillFinish:self];
        }
    }
}

- (void)snakkInterstitialAdActionDidFinish:(SnakkInterstitialAd *)interstitialAd {
    if (self.adView.isMRAID) {
        self.adView.mraidState = SNAKK_MRAID_STATE_HIDDEN;
        [self.adView syncMraidState];
        [self.adView fireMraidEvent:SNAKK_MRAID_EVENT_STATECHANGE withParams:self.adView.mraidState];
    }

    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdActionDidFinish:)]) {
            [self.delegate snakkInterstitialAdActionDidFinish:self];
        }
    }
}


#pragma mark -
#pragma mark MRAID methods

- (NSDictionary *)mraidQueryState {
    NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"interstitial", @"placementType",
                           nil];
    return state;
}


- (UIViewController *)mraidPresentingViewController {
    return self.presentingController;
}

- (void)mraidClose {
    [self.adController closeTapped:nil];
}

- (void)mraidAllowOrientationChange:(BOOL)isOrientationChangeAllowed andForceOrientation:(SnakkMraidForcedOrientation)forcedOrientation {
    
}

- (void)mraidResize:(CGRect)frame withUrl:(NSURL *)url isModal:(BOOL)isModal useCustomClose:(BOOL)useCustomClose {
    // unused for interstitials
}

- (void)mraidOpen:(NSString *)urlStr {
    BOOL shouldLoad = YES;
    if ([self.delegate respondsToSelector:@selector(snakkInterstitialAdActionShouldBegin:willLeaveApplication:)]) {
        // app has something to say about allowing tap to proceed...
        shouldLoad = [self.delegate snakkInterstitialAdActionShouldBegin:self willLeaveApplication:NO];
    }
    
    if (shouldLoad) {
        [self openURLInFullscreenBrowser:[NSURL URLWithString:urlStr]];
    }
    else {
        if (self.adView.isMRAID) {
            [self.adView fireMraidEvent:@"error" withParams:@"[\"Application declined to open browser\", \"open\"]"];
        }
    }
}

- (void)mraidUseCustomCloseButton:(BOOL)useCustomCloseButton {
    self.useCustomClose = useCustomCloseButton;
    if (useCustomCloseButton) {
        [self.adController hideCloseButton];
    }
    else {
        [self.adController showCloseButton];
    }
}


#pragma mark -
#pragma mark SnakkBrowserController methods

//- (void)openURLInFullscreenBrowser:(NSURL *)url {
//    BOOL shouldLoad = [self.snakkDelegate snakkInterstitialAdActionShouldBegin:nil willLeaveApplication:NO];
//    if (!shouldLoad) {
//        id<SnakkInterstitialAdDelegate> tDel = [self.snakkDelegate retain];
//        [self dismissViewControllerAnimated:self.animated completion:^{
//            [tDel snakkInterstitialAdDidUnload:nil];
//            [tDel release];
//        }];
//        return;
//    }
//    
//    // Present ad browser.
//    self.browserController = [[[SnakkBrowserController alloc] init] autorelease];
////    [self presentModalViewController:browserController animated:self.animated];
////    [self presentModalViewController:browserController animated:NO];
////    [browserController release];
//}

- (void)openURLInFullscreenBrowser:(NSURL *)url {
//    TILog(@"Banner->openURLInFullscreenBrowser: %@", url);
    self.browserController = [[[SnakkBrowserController alloc] init] autorelease];
    self.browserController.presentingController = self.presentingController;
    self.browserController.delegate = self;
    self.browserController.showLoadingOverlay = self.showLoadingOverlay;
    [self.browserController loadUrl:url];
    [self.adController showLoading];

    self.adController.closeButton.hidden = YES;
}

- (BOOL)browserControllerShouldLoad:(SnakkBrowserController *)theBrowserController willLeaveApp:(BOOL)willLeaveApp {
//    TILog(@"************* browserControllerShouldLoad:willLeaveApp:%d, (%@)", willLeaveApp, theBrowserController.url);
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkInterstitialAdActionShouldBegin:willLeaveApplication:)]) {
        [self.delegate snakkInterstitialAdActionShouldBegin:self willLeaveApplication:willLeaveApp];
    }
    return YES;
}

- (void)browserControllerLoaded:(SnakkBrowserController *)theBrowserController willLeaveApp:(BOOL)willLeaveApp {
//    TILog(@"************* browserControllerLoaded:willLeaveApp:");
    [self.adController dismissModalViewControllerAnimated:NO];
    [self.browserController showFullscreenBrowserAnimated:NO];
    self.adController = nil;
}

-(void)browserControllerWillDismiss:(SnakkBrowserController *)browserController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkInterstitialAdActionWillFinish:)]) {
        [self.delegate snakkInterstitialAdActionWillFinish:self];
    }
}

- (void)browserControllerDismissed:(SnakkBrowserController *)theBrowserController {
//    TILog(@"************* browserControllerDismissed:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkInterstitialAdActionDidFinish:)]) {
        [self.delegate snakkInterstitialAdActionDidFinish:self];
    }
    [self snakkInterstitialAdDidUnload:self];
}

- (void)browserControllerFailedToLoad:(SnakkBrowserController *)theBrowserController withError:(NSError *)error {
//    TILog(@"************* browserControllerFailedToLoad:withError: %@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkInterstitialAdActionDidFinish:)]) {
        [self.delegate snakkInterstitialAdActionDidFinish:self];
    }
    [self.adController hideLoading];
}

#pragma mark -


- (void)timerElapsed {
    // This method should be overridden by child class
}

- (UIViewController *)getDelegate {
    return (UIViewController *)self.delegate;
}

- (void)dealloc {
    self.adRequest = nil;
    self.adView = nil;
    self.adManager = nil;
    self.bannerView = nil;
    self.presentingView = nil;
    
    [super dealloc];
}

@end
