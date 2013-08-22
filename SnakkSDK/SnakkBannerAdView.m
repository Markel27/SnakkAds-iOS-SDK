//
//  SnakkBannerAd.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "SnakkBannerAdView.h"
#import "SnakkAdView.h"
#import "SnakkAppTracker.h"
#import "SnakkAdManager.h"
#import "SnakkPrivateConstants.h"
#import "SnakkBrowserController.h"
#import "SnakkRequest.h"

@interface SnakkBannerAdView () <SnakkAdManagerDelegate, SnakkBrowserControllerDelegate, SnakkMraidDelegate> {
    NSTimer *timer;
    BOOL isServingAds;
    BOOL isLoading;
    UIActivityIndicatorView *loadingSpinner;
    
    
    
    
    UIViewController *vc;
}

@property (retain, nonatomic) SnakkRequest *adRequest;
@property (retain, nonatomic) SnakkAdView *adView;
@property (retain, nonatomic) SnakkAdView *secondAdView;
@property (retain, nonatomic) SnakkAdManager *adManager;
@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGAffineTransform originalTransform;
@property (assign, nonatomic) UIView *originalSuperView;
@property (retain, nonatomic) SnakkBrowserController *browserController;
@property (retain, nonatomic) UIButton *closeButton;
@property (retain, nonatomic) UIViewController *fullscreenVC;



- (void)commonInit;
- (void)openURLInFullscreenBrowser:(NSURL *)url;
- (UIViewAnimationTransition)getRandomTransition;

//- (void)setFrameOffscreen;
- (void)startBannerRotationTimerForNormalOrError:(BOOL)isError; //TODO make this read better

@end


@implementation SnakkBannerAdView

@synthesize originalFrame, originalTransform, adView, secondAdView, adRequest, adManager, originalSuperView, animated, autoReposition, showLoadingOverlay, delegate, hideDirection, browserController, presentingController, shouldReloadAfterTap;

- (void)commonInit {
    self.originalFrame = [self frame];
    self.hideDirection = SnakkBannerHideNone;
    [self hide]; // hide the ad view until we have an ad to place in it
//    self.animated = YES; //default value
    self.adManager = [[[SnakkAdManager alloc] init] autorelease];
    self.adManager.delegate = self;
    isServingAds = NO;
    isLoading = NO;
    loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    [loadingSpinner sizeToFit];
    loadingSpinner.hidesWhenStopped = YES;
    self.autoReposition = YES;
    self.showLoadingOverlay = YES;
    vc = nil;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (BOOL)startServingAdsForRequest:(SnakkRequest *)request {
    self.adRequest = request;
    [self.adRequest setCustomParameter:SNAKK_AD_TYPE_BANNER forKey:@"adtype"];
    CGRect frame = self.frame;
    NSString *width = [NSString stringWithFormat:@"%d", (NSInteger)frame.size.width];
    NSString *height = [NSString stringWithFormat:@"%d", (NSInteger)frame.size.height];
    [self.adRequest setCustomParameter:width forKey:@"w"];
    [self.adRequest setCustomParameter:height forKey:@"h"];
    [self.adManager fireAdRequest:self.adRequest];
    isServingAds = YES;
    isLoading = YES;
    return YES;
}

- (void)resume {
    if (!isLoading) {
        [self requestAnotherAd];
    }
}

- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.originalSuperView) {
        // adview is attached to window, do orientation transforms manually
        [self.adView repositionToInterfaceOrientation:orientation];
        return;
    }
    
    if (!self.autoReposition) {
        // don't reposition banner, someone else will do it...
        return;
    }
    
    //TODO notify AdView of orientation change

    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        // swap width <--> height
        size = CGSizeMake(size.height, size.width);
    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    CGFloat x = 0, y = self.originalFrame.origin.y;
    CGFloat w = self.adView.frame.size.width, h = self.adView.frame.size.height;

    x = size.width/2 - self.adView.frame.size.width/2;

    if(self.animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setFrame:CGRectMake(x, y, w, h)];
        }
                         completion:^(BOOL finished){}
        ];
    }
    else {
        [self setFrame:CGRectMake(x, y, w, h)];
    }
}

- (CGRect)getHiddenFrameForDirection:(SnakkBannerHideDirection)direction {
    //TODO: Auto direction selection based on ad positioning
    CGRect hiddenFrame = {{0,0}, self.frame.size};
    switch (direction) {
        case SnakkBannerHideLeft:
            hiddenFrame.origin.x = - hiddenFrame.size.width;
            break;
            
        case SnakkBannerHideRight:
            hiddenFrame.origin.x = hiddenFrame.size.width;
            break;
            
        case SnakkBannerHideUp:
            hiddenFrame.origin.y = - hiddenFrame.size.height;
            break;
            
        case SnakkBannerHideDown:
            hiddenFrame.origin.y = hiddenFrame.size.height;
            break;
        case SnakkBannerHideNone:
        default:
            break;
    }
    
    return hiddenFrame;
}

- (void)hide {
    if (!self.adView) {
        // no ad, hide the container
        self.alpha = 0.0;
        return;
    }
    
    CGRect avFrame = [self getHiddenFrameForDirection:self.hideDirection];
    if (self.animated) {
        // mask the ad area so we can slide it away
        // mask should be reset here, just in case the ad size changes
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.adView.frame.size.width, self.adView.frame.size.height)];
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
        
        UIViewAnimationOptions optns = UIViewAnimationOptionCurveEaseOut;
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:optns
                         animations:^{
                             if (self.hideDirection == SnakkBannerHideNone) {
                                 self.alpha = 0.0;
                             }
                             self.adView.frame = avFrame;
                         }
                         completion:^(BOOL finished){ 
                             self.alpha = 0.0;
                             [self.adView setIsVisible:NO];
                         }
         ];
    }
    else {
        // just move it
        self.adView.frame = avFrame;
        self.alpha = 0.0;
        [self.adView setIsVisible:NO];
    }
}
#pragma mark -
#pragma mark SnakkAdManagerDelegate methods

- (void)willLoadAdWithRequest:(SnakkRequest *)request {
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdViewWillLoadAd:)]) {
        [self.delegate snakkBannerAdViewWillLoadAd:self];
    }
}

- (void)didLoadAdView:(SnakkAdView *)theAdView {
    SnakkAdView *oldAd = [self.adView retain];
    self.alpha = 1.0;
    self.adView = theAdView;
    self.adView.mraidDelegate = self;
    [self.adView setIsVisible:YES];
    
    if (self.animated) {
        UIViewAnimationTransition trans = (nil != self.adView ? [self getRandomTransition] : UIViewAnimationTransitionCurlDown);
        [UIView animateWithDuration:2
                              delay:0.0
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                            [UIView setAnimationTransition:trans forView:self cache:YES];
                            [self addSubview:self.adView];
                         }
                         completion:^(BOOL finished){ 
                             [oldAd removeFromSuperview];
                         }
         ];
    }
    else {
        [self addSubview:self.adView];
        [self addSubview:loadingSpinner];
        [oldAd removeFromSuperview];
    }
    
    isLoading = NO;
    [self startBannerRotationTimerForNormalOrError:NO];
    
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdViewDidLoadAd:)]) {
        [self.delegate snakkBannerAdViewDidLoadAd:self];
    }
    
    [oldAd release];
}

- (void)adView:(SnakkAdView *)adView didFailToReceiveAdWithError:(NSError*)error {
    [self hide];
    isLoading = NO;
    [self startBannerRotationTimerForNormalOrError:YES];
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdView:didFailToReceiveAdWithError:)]) {
        [self.delegate snakkBannerAdView:self didFailToReceiveAdWithError:error];
    }
}

- (BOOL)adActionShouldBegin:(NSURL *)actionUrl willLeaveApplication:(BOOL)willLeave {
    BOOL shouldLoad = YES;
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdViewActionShouldBegin:willLeaveApplication:)]) {
        // app has something to say about allowing tap to proceed...
        shouldLoad = [self.delegate snakkBannerAdViewActionShouldBegin:self willLeaveApplication:willLeave];
    }
    
    if (shouldLoad) {
        [self openURLInFullscreenBrowser:actionUrl];
    }
    
    // we've handled the action, don't allow the button press to propagate...
    return NO;
}

- (void)adViewActionDidFinish:(SnakkAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdViewActionDidFinish:)]) {
        [self.delegate snakkBannerAdViewActionDidFinish:self];
    }
}

- (void)requestAnotherAd {
//    [self mraidClose];
    [self cancelAds];
    if(!isLoading) {
        [self startServingAdsForRequest:self.adRequest];
    }
}

- (void)cancelAds {
    // Tell adManager to stop fetching ads
    isServingAds = NO;
    [self stopTimer];
    [adManager cancelAdRequests];
    isLoading = NO;
}

- (void)pause {
    [self cancelAds];
    isServingAds = YES;
}

#pragma mark -
#pragma mark MRAID delegate methods

- (NSDictionary *)mraidQueryState {
    NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"inline", @"placementType",
                           nil];
    return state;
}

- (UIViewController *)mraidPresentingViewController {
    return self.presentingController;
}

- (void)mraidAllowOrientationChange:(BOOL)isOrientationChangeAllowed andForceOrientation:(SnakkMraidForcedOrientation)forcedOrientation {
    
}

- (void)mraidResize:(CGRect)frame withUrl:(NSURL *)url isModal:(BOOL)isModal useCustomClose:(BOOL)useCustomClose {
    // isModal == YES: going full screen, NO: partial screen resize... detach and go UIWindow mode
    
    [self stopTimer];
    if ([SNAKK_MRAID_STATE_EXPANDED isEqualToString:self.adView.mraidState]) {
        TILog(@"Trying to resize an expanded ad!");
        // can't resize an expanded ad...
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionShouldBegin:willLeaveApplication:)]) {
        [self.delegate snakkBannerAdViewActionShouldBegin:self willLeaveApplication:NO];
    }
    
    if (url) {
        // load content as a two part creative
        SnakkAdView *sav = [[SnakkAdView alloc] initWithFrame:self.adView.frame];
        self.secondAdView = sav;
        [sav release];

        NSURLRequest *urlreq = [[NSURLRequest alloc] initWithURL:url];
        [self.secondAdView loadRequest:urlreq];
        [urlreq release];
    }
    
    SnakkAdView *theView = self.secondAdView ? self.secondAdView : self.adView;

    UIWindow *keyWindow = SnakkKeyWindow();
    if (theView.superview != keyWindow) {
        // move adview onto UIWindow
        CGRect transFrame = [keyWindow convertRect:self.adView.bounds fromView:self.adView];
        theView.frame = transFrame;
        [theView removeFromSuperview];
        [keyWindow addSubview:theView];

    }

    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         if (UIInterfaceOrientationIsPortrait(SnakkInterfaceOrientation())) {
                             theView.frame = frame;
                         }
                         else {
                             CGRect translatedFrame = CGRectMake(frame.origin.y, frame.origin.x, frame.size.height, frame.size.width);
                             theView.frame = translatedFrame;
                         }
                     }
                     completion:^(BOOL finished) {
                         if (isModal) {
                             [self mraidGoFullscreenUseCustomClose:useCustomClose];
                         }
                         else {
                             self.adView.mraidState = SNAKK_MRAID_STATE_RESIZED;
                             [self.adView syncMraidState];
                             [self.adView fireMraidEvent:SNAKK_MRAID_EVENT_STATECHANGE withParams:self.adView.mraidState];
                         }
                     }
     ];
}

- (void)mraidGoFullscreenUseCustomClose:(BOOL)useCustomClose {
    // move adView from UIWindow into a VC, then push VC onto stack w/o animations
    if (!vc) {
        SnakkAdView *theView;
        if(self.secondAdView) {
            // two part creative mode...
            theView = self.secondAdView;
        }
        else {
            theView = self.adView;
        }
    
        vc = [[UIViewController alloc] init];
        vc.view = theView;
        
        //TODO: support iOS 4.x        
        UIViewController *pvc = self.presentingController;
        if(!pvc) {
            pvc = SnakkTopViewController();
        }
        
        [pvc presentViewController:vc animated:NO completion:^{
            TILog(@"Presenting VC: %@ from %@", vc, self.presentingController);
            self.adView.mraidState = SNAKK_MRAID_STATE_EXPANDED;
            [self.adView syncMraidState];
            [self.adView fireMraidEvent:SNAKK_MRAID_EVENT_STATECHANGE withParams:self.adView.mraidState];

            if (!useCustomClose) {
                [self showCloseButton];
            }
        }];
    }
}

- (void)mraidOpen:(NSString *)urlStr {
    BOOL shouldLoad = YES;
    if ([self.delegate respondsToSelector:@selector(snakkBannerAdViewActionShouldBegin:willLeaveApplication:)]) {
        // app has something to say about allowing tap to proceed...
        shouldLoad = [self.delegate snakkBannerAdViewActionShouldBegin:self willLeaveApplication:NO];
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
    if (useCustomCloseButton) {
        [self hideCloseButton];
    }
    else {
        [self showCloseButton];
    }
}

- (void)mraidClose {
    
    if([@"default" isEqualToString:self.adView.mraidState]) {
        // transition to hidden state
        [self hide];
        self.adView.mraidState = SNAKK_MRAID_STATE_HIDDEN;
    }
    else {
        // transition to default state
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionWillFinish:)]) {
            [self.delegate snakkBannerAdViewActionWillFinish:self];
        }
        
        [self hideCloseButton];
        
        if (vc) {
            [vc dismissViewControllerAnimated:NO completion:^{
                [vc release]; vc = nil;
            }];
        }
        
        if (self.secondAdView) {
            self.secondAdView = nil;
        }
        else {
            // re-attach the ad view to the banneradview container
            [self.adView removeFromSuperview];
            [self addSubview:self.adView];
            self.adView.frame = self.bounds;
        }
        self.adView.mraidState = SNAKK_MRAID_STATE_DEFAULT;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionDidFinish:)]) {
            [self.delegate snakkBannerAdViewActionDidFinish:self];
        }
        
        [self startBannerRotationTimerForNormalOrError:YES];
    }
    
    [self.adView syncMraidState];
    [self.adView fireMraidEvent:SNAKK_MRAID_EVENT_STATECHANGE withParams:self.adView.mraidState];
}

- (void)closeTapped:(id)sender {
    TILog(@"close tapped!");
    [self mraidClose];
}

- (void)showCloseButton {
    if (!self.closeButton) {

        UIImage *closeButtonBackground = [UIImage imageNamed:@"Snakk.bundle/interstitial_close_button.png"];
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.closeButton.imageView.contentMode = UIViewContentModeCenter;
        [self.closeButton setImage:closeButtonBackground forState:UIControlStateNormal];
        
        [self.closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.adView addSubview:self.closeButton];
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;

        CGRect appFrame = SnakkApplicationFrame(SnakkInterfaceOrientation());
        self.closeButton.frame = CGRectMake(appFrame.size.width - 50, 0, 50, 50);
    }

    [self bringSubviewToFront:self.closeButton];
}

- (void)hideCloseButton {
    if (!self.closeButton) {
        return;
    }
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
}

#pragma mark -

- (UIViewAnimationTransition)getRandomTransition {
    int transIdx = random() % 5;
    switch (transIdx) {
        case 0:
            return UIViewAnimationTransitionCurlUp;
            break;
            
        case 1:
            return UIViewAnimationTransitionCurlDown;
            break;
            
        case 2:
            return UIViewAnimationTransitionFlipFromLeft;
            break;
            
        case 3:
            return UIViewAnimationTransitionFlipFromRight;
            break;
            
        case 4:
            return UIViewAnimationTransitionNone;
            break;
            
        default:
            return UIViewAnimationTransitionNone;
            break;
    }
}

#pragma mark -
#pragma mark Timer methods

- (BOOL)isServingAds {
    return isServingAds;
}

- (void)startTimerForSeconds:(NSTimeInterval)seconds {
    [self stopTimer];
    timer = [[NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(timerElapsed) userInfo:nil repeats:NO] retain];
}

- (void)timerElapsed {
    // fire off another ad request...
    [self requestAnotherAd];
}

- (void)stopTimer {
    [timer invalidate];
    [timer release], timer = nil;
}

- (void)startBannerRotationTimerForNormalOrError:(BOOL)isError {
    if (!isServingAds) {
        // banner has been canceled, don't re-start timer
        return;
    }
    
    NSString *key = isError ? SNAKK_PARAM_KEY_BANNER_ERROR_TIMEOUT_INTERVAL : SNAKK_PARAM_KEY_BANNER_ROTATE_INTERVAL;
    NSNumber *durObj = [self.adRequest customParameterForKey:key];
    NSTimeInterval duration;
    if (durObj) {
        duration = [durObj intValue];
    }
    else {
        duration = isError ? SNAKK_PARAM_VALUE_BANNER_ERROR_TIMEOUT_INTERVAL : SNAKK_PARAM_VALUE_BANNER_ROTATE_INTERVAL;
    }
    
    [self startTimerForSeconds:duration];
}

- (UIViewController *)getDelegate {
    return (UIViewController *)self.delegate;
}


- (void)showLoading {
    if(!self.showLoadingOverlay) {
        [self addSubview:loadingSpinner];
        loadingSpinner.center = self.center;
        [loadingSpinner startAnimating];
    }
}

- (void)hideLoading {
    if (!self.showLoadingOverlay) {
        [loadingSpinner stopAnimating];
        [loadingSpinner removeFromSuperview];
    }
}

#pragma mark -
#pragma mark SnakkBrowserController methods

- (void)openURLInFullscreenBrowser:(NSURL *)url {
    TILog(@"Banner->openURLInFullscreenBrowser: %@", url);
    [self stopTimer];
    self.browserController = [[[SnakkBrowserController alloc] init] autorelease];
    self.browserController.delegate = self;
    if(vc) {
        self.browserController.presentingController = vc;
    }
    else if(self.presentingController) {
        self.browserController.presentingController = self.presentingController;
    }
    self.browserController.showLoadingOverlay = self.showLoadingOverlay;
    [self.browserController loadUrl:url];
    [self showLoading];
}

- (BOOL)browserControllerShouldLoad:(SnakkBrowserController *)theBrowserController willLeaveApp:(BOOL)willLeaveApp {
//    TILog(@"************* browserControllerShouldLoad:willLeaveApp:%d, (%@)", willLeaveApp, theBrowserController.url);
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionShouldBegin:willLeaveApplication:)]) {
        [self.delegate snakkBannerAdViewActionShouldBegin:self willLeaveApplication:willLeaveApp];
    }
    return YES;
}

- (void)browserControllerLoaded:(SnakkBrowserController *)theBrowserController willLeaveApp:(BOOL)willLeaveApp {
//    TILog(@"************* browserControllerLoaded:willLeaveApp:");
    [self hideLoading];
    if (!willLeaveApp) {
        [self.browserController showFullscreenBrowser];
    }
}

- (void)browserControllerWillDismiss:(SnakkBrowserController *)theBrowserController {
//    TILog(@"************* browserControllerWillDismiss:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionWillFinish:)]) {
        [self.delegate snakkBannerAdViewActionWillFinish:self];
    }
    [self hideLoading];
//    if (self.shouldReloadAfterTap) {
//        [self requestAnotherAd];
//    }
}

- (void)browserControllerDismissed:(SnakkBrowserController *)theBrowserController {
//    TILog(@"************* browserControllerDismissed:");
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionDidFinish:)]) {
        [self.delegate snakkBannerAdViewActionDidFinish:self];
    }
    [self hideLoading];
//    if (self.shouldReloadAfterTap) {
//        [self requestAnotherAd];
//    }
}

- (void)browserControllerFailedToLoad:(SnakkBrowserController *)theBrowserController withError:(NSError *)error {
//    TILog(@"************* browserControllerFailedToLoad:withError: %@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkBannerAdViewActionDidFinish:)]) {
        [self.delegate snakkBannerAdViewActionDidFinish:self];
    }
    [self hideLoading];
//    if (self.shouldReloadAfterTap) {
//        [self requestAnotherAd];
//    }
}


#pragma mark -
#pragma mark geotargeting code
- (NSUInteger)locationPrecision {
    return self.adRequest.locationPrecision;
}

- (void)setLocationPrecision:(NSUInteger)locationPrecision {
    if (locationPrecision != self.adRequest.locationPrecision) {
        self.adRequest.locationPrecision = locationPrecision;
    }
}

- (void)updateLocation:(CLLocation *)location {
    [self.adRequest updateLocation:location];
}

#pragma mark -

- (void)dealloc {
    [vc release]; vc = nil;
    [self cancelAds];
    self.adView = nil;
    self.adRequest = nil;
    self.adManager = nil;
    self.delegate = nil;
//    self.browserController = nil;
    [super dealloc];
}
@end
