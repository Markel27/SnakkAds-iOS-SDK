//
//  AdPromptDemoController
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "AppDelegate.h"
#import "AdPromptDemoController.h"
#import "Snakk.h"
#import "SnakkAdPrompt.h"
#import "BackgroundHelper.h"

// This is the zone id for the AdPrompt Example
// go to http://ads.snakkads.com/ to get your's
#define ZONE_ID @"31379"


@interface AdPromptDemoController ()

@end

@implementation AdPromptDemoController

@synthesize preloadButton;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
}

- (void)viewDidAppear:(BOOL)animated {
//    [self simpleExample];
}

#pragma mark -
#pragma mark SnakkAdPrompt Example code
- (void)simpleExample:(id)sender {
    SnakkRequest *request = [SnakkRequest requestWithAdZone:ZONE_ID];
    SnakkAdPrompt *prompt = [[[SnakkAdPrompt alloc] initWithRequest:request] autorelease];
    [prompt showAsAlert];
}


- (void)loadAdPrompt {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"test", @"mode", // enable test mode to test AdPrompts in your app
                            nil];
    SnakkRequest *request = [SnakkRequest requestWithAdZone:ZONE_ID andCustomParameters:params];
    AppDelegate *myAppDelegate = (AppDelegate *)([[UIApplication sharedApplication] delegate]);
    [request updateLocation:myAppDelegate.locationManager.location];
    snakkAdPrompt = [[SnakkAdPrompt alloc] initWithRequest:request];
    snakkAdPrompt.delegate = self;

    snakkAdPrompt.showLoadingOverlay = YES;
}

- (IBAction)preLoadAdPrompt:(id)sender {
    [self loadAdPrompt];
    [snakkAdPrompt load];
}

- (IBAction)showAdPrompt:(id)sender {
    if (!snakkAdPrompt) {
        [self loadAdPrompt];
    }
    
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1) {
        [snakkAdPrompt showAsActionSheet];
    }
    else {
        [snakkAdPrompt showAsAlert];
    }
}

- (void)snakkAdPrompt:(SnakkAdPrompt *)adPrompt didFailWithError:(NSError *)error {
    NSLog(@"Error showing AdPrompt: %@", error);
    [self cleanupAdPrompt];
}

- (void)snakkAdPromptWasDeclined:(SnakkAdPrompt *)adPrompt {
    NSLog(@"AdPrompt was DECLINED!");
    [self cleanupAdPrompt];
}

- (void)snakkAdPromptDidLoad:(SnakkAdPrompt *)adPrompt {
    NSLog(@"AdPrompt loaded!");
    self.preloadButton.enabled = NO;
}

- (void)snakkAdPromptWasDisplayed:(SnakkAdPrompt *)adPrompt {
    NSLog(@"AdPrompt displayed!");
}

- (BOOL)snakkAdPromptActionShouldBegin:(SnakkAdPrompt *)adPrompt willLeaveApplication:(BOOL)willLeave {
    NSString *strWillLeave = willLeave ? @"Leaving app" : @"loading internally";
    NSLog(@"AdPrompt was accepted, loading app/advertisement... %@", strWillLeave);
    return YES;
}

- (void)snakkAdPromptActionDidFinish:(SnakkAdPrompt *)adPrompt {
    NSLog(@"AdPrompt Action finished!");
    [self cleanupAdPrompt];
}


- (void)cleanupAdPrompt {
    [snakkAdPrompt release]; snakkAdPrompt = nil;
    self.preloadButton.enabled = YES;
}

#pragma mark -

- (void)dealloc {
    [self cleanupAdPrompt];
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
