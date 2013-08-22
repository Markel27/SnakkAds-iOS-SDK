//
//  SecondViewController.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "AppDelegate.h"
#import "InterstitialController.h"
#import "Snakk.h"
#import "BackgroundHelper.h"


// This is the zone id for the Interstitial Example
// go to http://ads.snakkads.com/ to get your's
#define ZONE_ID @"31375"

@interface InterstitialController ()

@end

@implementation InterstitialController

@synthesize activityIndicator;
@synthesize loadButton;
@synthesize showButton;
@synthesize interstitialAd;


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
}

- (void)viewDidUnload
{
    [self setLoadButton:nil];
    [self setShowButton:nil];
    [self setActivityIndicator:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Button handling

- (IBAction)loadInterstitial:(id)sender {
    [self updateUIWithState:StateLoading];
    self.interstitialAd = [[[SnakkInterstitialAd alloc] init] autorelease];
    self.interstitialAd.delegate = self;
    self.interstitialAd.animated = YES;
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:  
//                            @"test", @"mode", // enable test mode to test banner ads in your app
                            nil];
    SnakkRequest *request = [SnakkRequest requestWithAdZone:ZONE_ID andCustomParameters:params];
    AppDelegate *myAppDelegate = (AppDelegate *)([[UIApplication sharedApplication] delegate]);
    [request updateLocation:myAppDelegate.locationManager.location];
    [self.interstitialAd loadInterstitialForRequest:request];
}

- (void)updateUIWithState:(ButtonState)state {
    [loadButton setEnabled:(state != StateLoading)];
    [showButton setHidden:(state != StateReady)];
    [activityIndicator setHidden:(state != StateLoading)];
}

- (IBAction)showInterstitial:(id)sender {
    [self.interstitialAd presentFromViewController:self];
}

#pragma mark -
#pragma mark SnakkInterstitialAdDelegate methods

- (void)snakkInterstitialAd:(SnakkInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
    [self updateUIWithState:StateError];
}

- (void)snakkInterstitialAdDidUnload:(SnakkInterstitialAd *)interstitialAd {
    NSLog(@"Ad did unload");
    [self updateUIWithState:StateNone];
    self.interstitialAd = nil; // don't reuse interstitial ad!
}

- (void)snakkInterstitialAdWillLoad:(SnakkInterstitialAd *)interstitialAd {
    NSLog(@"Ad will load");
}

- (void)snakkInterstitialAdDidLoad:(SnakkInterstitialAd *)interstitialAd {
    NSLog(@"Ad did load");
    [self updateUIWithState:StateReady];
}

- (BOOL)snakkInterstitialAdActionShouldBegin:(SnakkInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave {
    NSLog(@"Ad action should begin");
    return YES;
}

- (void)snakkInterstitialAdActionDidFinish:(SnakkInterstitialAd *)interstitialAd {
    NSLog(@"Ad action did finish");
}


#pragma mark -

- (void)dealloc {
    self.loadButton = nil;
    self.showButton = nil;
    self.activityIndicator = nil;
    self.interstitialAd = nil;
    [_backgroundImageView release];
    [super dealloc];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
}
@end
