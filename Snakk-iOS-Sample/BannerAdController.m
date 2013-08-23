//
//  FirstViewController.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "AppDelegate.h"
#import "BannerAdController.h"
#import "Snakk.h"
#import "BackgroundHelper.h"

// This is the zone id for the BannerAd Example
// go to http://ads.snakkads.com/ to get one for your app.
#define ZONE_ID (IS_IPAD ? @"31381" : @"31373")

@implementation BannerAdController

@synthesize snakkAd;

/**
 * this is the easiest way to add banner ads to your app.
 */
- (void)initBannerSimple {
    // init banner and add to your view
    if (!snakkAd) {
        // don't re-define if we used IB to init the banner...
        snakkAd = [[SnakkBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [self.view addSubview:self.snakkAd];
    }

    // kick off banner rotation!
    [self.snakkAd startServingAdsForRequest:[SnakkRequest requestWithAdZone:ZONE_ID]];
}

/**
 * a more advanced example that shows how to:
 * - enable ad lifecycle notifications(see SnakkBannerAdViewDelegate methods section below)
 * - turn on test mode
 * - enable gps based geo-targeting
 */
- (void)initBannerAdvanced {
    // init banner and add to your view
    if (!snakkAd) {
        // don't re-define if we used IB to init the banner...
        snakkAd = [[SnakkBannerAdView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
        [self.view addSubview:self.snakkAd];
    }
    
    // get notifiactions of ad lifecycle events (will load, did load, error, etc...)
    self.snakkAd.delegate = self;

    // BETA: show a loading overlay when ad is pressed
    self.snakkAd.showLoadingOverlay = YES;

    // set the parent controller for modal browser that loads when user taps ad
//    self.snakkAd.presentingController = self; // only needed if tapping banner doesn't load modal browser properly
    
    // customize the request...
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"test", @"mode", // enable test mode to test banner ads in your app
                            nil];
    SnakkRequest *request = [SnakkRequest requestWithAdZone:ZONE_ID andCustomParameters:params];
    
    // this is how you enable location updates... NOTE: only enable if your app has a good reason to know the users location (apple will reject your app if not)
    AppDelegate *myAppDelegate = (AppDelegate *)([[UIApplication sharedApplication] delegate]);
    [request updateLocation:myAppDelegate.locationManager.location];
    
    // kick off banner rotation!
    [self.snakkAd startServingAdsForRequest:request];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // easiest way to get banners displaying in your app...
//    [self initBannerSimple];
    
//    // - OR - the more advanced way... (use simple or advanced, but not both)
    [self initBannerAdvanced];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
}

- (IBAction)hideBanner:(id)sender {
    [self.snakkAd hide];
}

- (IBAction)cancelLoad:(id)sender {
    [self.snakkAd cancelAds];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.snakkAd resume];
}
- (void)viewWillDisappear:(BOOL)animated {
    [self.snakkAd pause];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // notify banner of orientation changes
    [self.snakkAd repositionToInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark -
#pragma mark SnakkBannerAdViewDelegate methods

- (void)snakkBannerAdViewWillLoadAd:(SnakkBannerAdView *)bannerView {
    NSLog(@"Banner is about to check server for ad...");
}

- (void)snakkBannerAdViewDidLoadAd:(SnakkBannerAdView *)bannerView {
    NSLog(@"Banner has been loaded...");
    // Banner view will display automatically if docking is enabled
    // if disabled, you'll want to show bannerView
}

- (void)snakkBannerAdView:(SnakkBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Banner failed to load with the following error: %@", error);
    // Banner view will hide automatically if docking is enabled
    // if disabled, you'll want to hide bannerView
}

- (BOOL)snakkBannerAdViewActionShouldBegin:(SnakkBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Banner was tapped, your UI will be covered up. %@", (willLeave ? @" !!LEAVING APP!!" : @""));
    // minimise app footprint for a better ad experience.
    // e.g. pause game, duck music, pause network access, reduce memory footprint, etc...
    return YES;
}

- (void)snakkBannerAdViewActionWillFinish:(SnakkBannerAdView *)bannerView {
    NSLog(@"Banner is about to be dismissed, get ready!");
    
}

- (void)snakkBannerAdViewActionDidFinish:(SnakkBannerAdView *)bannerView {
    NSLog(@"Banner is done covering your app, back to normal!");
    // resume normal app functions
}

#pragma mark -

- (void)dealloc {
    self.snakkAd = nil;
    [_backgroundImageView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
}
@end
