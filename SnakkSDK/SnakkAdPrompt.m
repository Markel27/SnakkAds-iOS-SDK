//
//  SnakkPopupAd.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "SnakkPrivateConstants.h"
#import "SnakkAdPrompt.h"
#import "SnakkAdManager.h"
#import "SnakkBrowserController.h"
#import "SnakkRequest.h"

typedef enum {
    SnakkAdPromptStateNew,
    SnakkAdPromptStateLoading,
    SnakkAdPromptStateLoaded,
    SnakkAdPromptStateShown,
    SnakkAdPromptStateError,
} SnakkAdPromptState;


@interface SnakkAdPrompt () <SnakkAdManagerDelegate, SnakkBrowserControllerDelegate> {
    BOOL isAlertType;
    SnakkAdPromptState state;
    BOOL displayImmediately;
}
@property (retain, nonatomic) SnakkRequest *adRequest;
@property (retain, nonatomic) SnakkAdManager *adManager;
@property (retain, nonatomic) NSString *clickUrl;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSString *callToAction;
@property (retain, nonatomic) NSString *declineString;
@property (retain, nonatomic) SnakkBrowserController *browserController;

- (void)performRequest;
- (void)performAdAction;
@end

@implementation SnakkAdPrompt

@synthesize delegate, adRequest, adManager, clickUrl, title, callToAction, declineString, browserController, showLoadingOverlay;

- (BOOL)loaded {
    return (state > SnakkAdPromptStateLoaded && state != SnakkAdPromptStateError);
}

- (id)initWithRequest:(SnakkRequest *)request {
    self = [super init];
    if (self) {
        self.adManager = [[[SnakkAdManager alloc] init] autorelease];
        self.adManager.delegate = self;
        self.adRequest = request;
        state = SnakkAdPromptStateNew;
        displayImmediately = NO;
        self.showLoadingOverlay = YES;
    }
    return self;
}

#pragma mark -
#pragma mark AlertAd Methods

- (void)load {
    if (state >= SnakkAdPromptStateLoading) {
        if (state >= SnakkAdPromptStateShown) {
            NSLog(@"Re-use of AdPrompt object is dissalowed.  Please instantiate a new AdPrompt.");
        }
        else if (state == SnakkAdPromptStateLoading) {
            NSLog(@"AdPrompt is currently loading, ignoring");
        }
        else {
            NSLog(@"AdPrompt was already loaded, ignoring");
        }
        return;
    }
    state = SnakkAdPromptStateLoading;
    [self performRequest];
}

- (void)showAsAlert {
    if (state >= SnakkAdPromptStateShown) {
        NSLog(@"Re-use of AdPrompt object is dissalowed.  Please instantiate a new AdPrompt.");
        return;
    }
    else if (state == SnakkAdPromptStateLoading) {
        NSLog(@"AdPrompt is currently loading. Please check adPrompt.loaded before showing");
        return;
    }
    else if (state == SnakkAdPromptStateNew) {
        [self retain];
        isAlertType = YES;
        displayImmediately = YES;
        [self load];
        return;
        // [self load] will bring us back here once data is available...
    }
    else if (!displayImmediately) {
        // was pre-loaded so we haven't yet self retained... do so now
        [self retain];
    }
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:self.title
                                                   delegate:self 
                                          cancelButtonTitle:self.declineString
                                          otherButtonTitles:self.callToAction, nil];
    [alert show];
    [self retain];
    [alert release];
    state = SnakkAdPromptStateShown;
    
    if ([self.delegate respondsToSelector:@selector(snakkAdPromptWasDisplayed:)]) {
        [self.delegate snakkAdPromptWasDisplayed:self];
    }
}

- (void)showAsActionSheet {
    if (state >= SnakkAdPromptStateShown) {
        NSLog(@"Re-use of AdPrompt object is dissalowed.  Please instantiate a new AdPrompt.");
        return;
    }
    else if (state == SnakkAdPromptStateLoading) {
        NSLog(@"AdPrompt is currently loading. Please check adPrompt.loaded before showing");
        return;
    }
    else if (state == SnakkAdPromptStateNew) {
        [self retain];
        isAlertType = NO;
        displayImmediately = YES;
        [self load];
        return;
        // [self load] will bring us back here once data is available...
    }
    else if (!displayImmediately) {
        // was pre-loaded so we haven't yet self retained... do so now
        [self retain];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.title
                                                    delegate:self 
                                           cancelButtonTitle:nil 
                                      destructiveButtonTitle:nil 
                                           otherButtonTitles:self.callToAction, self.declineString, nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    
    [actionSheet showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [actionSheet release];
    state = SnakkAdPromptStateShown;
    
    if ([self.delegate respondsToSelector:@selector(snakkAdPromptWasDisplayed:)]) {
        [self.delegate snakkAdPromptWasDisplayed:self];
    }
}

#pragma mark -
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    TILog(@"UIAlertView: dismissed with button: %d", buttonIndex);
    if (buttonIndex == 1) { // second button is the call to action...
        BOOL performAction = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptActionShouldBegin:willLeaveApplication:)]) {
            performAction = [self.delegate snakkAdPromptActionShouldBegin:self willLeaveApplication:NO];
        }
        if (performAction) {
            [self performAdAction];
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptWasDeclined:)]) {
            [self.delegate snakkAdPromptWasDeclined:self];
        }
        [self release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    TILog(@"UIActionSheet: dismissed with button: %d", buttonIndex);
    if (buttonIndex == 0) { // top button is the call to action...
        BOOL performAction = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptActionShouldBegin:willLeaveApplication:)]) {
            performAction = [self.delegate snakkAdPromptActionShouldBegin:self willLeaveApplication:NO];
        }
        if (performAction) {
            [self performAdAction];
        }
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptWasDeclined:)]) {
            [self.delegate snakkAdPromptWasDeclined:self];
        }
        [self release];
    }
    
}

- (void)performRequest {
    [self.adRequest setCustomParameter:SNAKK_AD_TYPE_ALERT forKey:@"adtype"];
    [self.adManager fireAdRequest:self.adRequest];
    // didReceiveData: or adView:didFailToReceiveAdWithError: get called next...
}

- (void)performAdAction {
    [self openURLInFullscreenBrowser:[NSURL URLWithString:self.clickUrl]];
}

#pragma mark -
#pragma mark SnakkBrowserController Delegate methods

- (void)openURLInFullscreenBrowser:(NSURL *)url {
    self.browserController = [[[SnakkBrowserController alloc] init] autorelease];
    self.browserController.delegate = self;
    self.browserController.showLoadingOverlay = self.showLoadingOverlay;
    [self.browserController loadUrl:url];
}

- (void)browserControllerFailedToLoad:(SnakkBrowserController *)browserController withError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPrompt:didFailWithError:)]) {
        [self.delegate snakkAdPrompt:self didFailWithError:error];
    }
    [self release];
}

- (BOOL)browserControllerShouldLoad:(SnakkBrowserController *)browserController willLeaveApp:(BOOL)willLeaveApp {
    BOOL shouldLoad = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptActionShouldBegin:willLeaveApplication:)]) {
        shouldLoad = [self.delegate snakkAdPromptActionShouldBegin:self willLeaveApplication:willLeaveApp];
    }
    return shouldLoad;
}

- (void)browserControllerLoaded:(SnakkBrowserController *)browserController willLeaveApp:(BOOL)willLeaveApp {
    if (!willLeaveApp) {
        [self.browserController showFullscreenBrowserAnimated:YES];
    }
}

- (void)browserControllerWillDismiss:(SnakkBrowserController *)browserController {
    // noop
}

- (void)browserControllerDismissed:(SnakkBrowserController *)browserController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(snakkAdPromptActionShouldBegin:willLeaveApplication:)]) {
        [self.delegate snakkAdPromptActionDidFinish:self];
    }
    [self release];
}




#pragma mark -
#pragma mark SnakkAdManager Delegate methods

- (void)willLoadAdWithRequest:(SnakkRequest *)request {
    
}

- (void)didLoadAdView:(SnakkAdView *)adView {
    // noop
}

- (void)adView:(SnakkAdView *)adView didFailToReceiveAdWithError:(NSError*)error {
    state = SnakkAdPromptStateError;
    if ([self.delegate respondsToSelector:@selector(snakkAdPrompt:didFailWithError:)]) {
        [self.delegate snakkAdPrompt:self didFailWithError:error];
    }
    if (displayImmediately) {
        // we didn't preload, release our internal retain
        [self release];
    }
}

- (BOOL)adActionShouldBegin:(NSURL *)actionUrl willLeaveApplication:(BOOL)willLeave {
    if ([self.delegate respondsToSelector:@selector(snakkAdPromptActionShouldBegin:willLeaveApplication:)]) {
        return [self.delegate snakkAdPromptActionShouldBegin:self willLeaveApplication:willLeave];
    }
    return YES;
}

- (void)adViewActionDidFinish:(SnakkAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(snakkAdPromptActionDidFinish:)]) {
        [self.delegate snakkAdPromptActionDidFinish:self];
    }
    [self release];
}

- (void)didReceiveData:(NSDictionary *)data {
    self.clickUrl = [NSString stringWithString:[data objectForKey:@"clickurl"]];
//    self.clickUrl = @"http://itunes.apple.com/us/app/tiny-village/id453126021?mt=8#";
    
    self.title = [data objectForKey:@"adtitle"];
    self.callToAction = [data objectForKey:@"calltoaction"];
    self.declineString = [data objectForKey:@"declinestring"];

    state = SnakkAdPromptStateLoaded;

    if ([self.delegate respondsToSelector:@selector(snakkAdPromptDidLoad:)]) {
        [self.delegate snakkAdPromptDidLoad:self];
    }
    
    if (displayImmediately) {
        if (isAlertType) {
            [self showAsAlert];
        }
        else {
            [self showAsActionSheet];
        }
    }
}

#pragma mark -

- (void)dealloc {
    self.delegate = nil;
    self.adRequest = nil;
    self.adManager = nil;
    self.clickUrl = nil;
    self.title = nil;
    self.callToAction = nil;
    self.declineString = nil;
    self.browserController = nil;
    [super dealloc];
}
@end
