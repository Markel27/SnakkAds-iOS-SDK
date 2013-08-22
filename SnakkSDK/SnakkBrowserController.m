//
//  SnakkBrowserController.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SnakkBrowserController.h"
#import "SnakkPrivateConstants.h"
#import "SnakkAppTracker.h"

@implementation SnakkBrowserController {
	UIWebView *_webView;
	UIBarButtonItem *_backButton;
	UIBarButtonItem *_forwardButton;
	UIBarButtonItem *_refreshButton;
	UIBarButtonItem *_safariButton;
	UIBarButtonItem *_doneButton;
	UIActivityIndicatorView *_spinner;
	UIBarButtonItem *_spinnerItem;
	UIActionSheet *_actionSheet;
    
    UIView *_hudView;
	UIActivityIndicatorView *_preloadingSpinner;
    UILabel *_hudCaption;
    
    UIViewController *presentingController;
    BOOL _isShowing;
    NSURL *url;
    BOOL statusBarVisibilityChanged;
    BOOL prevStatusBarHiddenState;
    
    UIViewController *theControllerToPresent;
}

@synthesize delegate, url, presentingController, showLoadingOverlay;

static NSArray *BROWSER_SCHEMES, *SPECIAL_HOSTS;
static Class inAppStoreVCClass;
+ (void)initialize 
{
	// Schemes that should be handled by the in-app browser.
	BROWSER_SCHEMES = [[NSArray arrayWithObjects:
						@"http",
						@"https",
                        @"about", // blank screen
						nil] retain];
	
	// Hosts that should be handled by the OS.
	SPECIAL_HOSTS = [[NSArray arrayWithObjects:
					  @"phobos.apple.com",
					  @"maps.google.com",
                      @"itunes.apple.com",
					  nil] retain];

#ifndef DISABLE_NEW_FEATURES
    inAppStoreVCClass = NSClassFromString(@"SKStoreProductViewController");
#else
    inAppStoreVCClass = nil;
#endif
}

- (id)init {
	if (self = [super init])
	{
        _isShowing = NO;
        statusBarVisibilityChanged = NO;
        prevStatusBarHiddenState = NO;
        UIWindow* window = [UIApplication sharedApplication].keyWindow;
        self.presentingController = window.rootViewController;
        theControllerToPresent = [self retain];
        [self buildUI];
	}
	return self;
}

/**
 * removes the advalidate.php hop, going straight to adclick.php
 */
- (void)rewriteUrl:(NSURL **)theUrl {
    NSString *urlString = [*theUrl absoluteString];
    NSString *testString = [NSString stringWithFormat:@"%@/advalidate.php?", SNAKK_CLICK_SERVER_BASE_URL];
    NSRange range = [urlString rangeOfString:testString];
    if (range.location != NSNotFound) {
        NSString *queryString = [urlString substringFromIndex:range.length];
        NSString *updatedUrlString = [NSString stringWithFormat:@"%@/adclick.php?%@", SNAKK_CLICK_SERVER_BASE_URL, queryString];
        *theUrl = [NSURL URLWithString:updatedUrlString];
        TILog(@"Re-writing url to: %@", *theUrl);
    }
}

- (void)loadUrl:(NSURL *)theUrl {
    // test urls...
//    theUrl = [NSURL URLWithString:@"http://www.snakkads.com/"];
//    theUrl = [NSURL URLWithString:@"http://itunes.apple.com/us/app/tiny-village/id453126021?mt=8#"];
//    theUrl = [NSURL URLWithString:@"https://itunes.apple.com/ua/app/dont-touch/id372842596?mt=8"];
    
//    TILog(@"Loading URL: %@", theUrl);
//    [self rewriteUrl:&theUrl];
//    TILog(@"New URL: %@", theUrl);
    [_webView loadRequest:[NSURLRequest requestWithURL:theUrl]];
    
    [self buildAndShowLoadingOverlay];
}

- (void)hideStatusBar {
//    UIApplication *app = [UIApplication sharedApplication];
//    BOOL currentState = app.statusBarHidden;
//    if (!currentState) {
//        app.statusBarHidden = YES;
//        prevStatusBarHiddenState = currentState;
//        statusBarVisibilityChanged = YES;
//    }
}

- (void)resetStatusBar {
//    if (statusBarVisibilityChanged) {
//        UIApplication *app = [UIApplication sharedApplication];
//        app.statusBarHidden = prevStatusBarHiddenState;
//        statusBarVisibilityChanged = NO;
//    }
}

- (void)buildAndShowLoadingOverlay {
    if (!self.showLoadingOverlay) {
        return;
    }
    int boxSize = 120;
    int fontSize = 16;
    int spinnerY = 30;
    int captionY = 85;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        boxSize = 170;
        fontSize = 20;
        spinnerY = 55;
        captionY = 115;
    }
    _hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, boxSize, boxSize)];
    _hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _hudView.clipsToBounds = YES;
    _hudView.layer.cornerRadius = 10.0;
    
    _preloadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _preloadingSpinner.frame = CGRectMake((boxSize/2)-(_preloadingSpinner.bounds.size.width/2), spinnerY, _preloadingSpinner.bounds.size.width, _preloadingSpinner.bounds.size.height);
    [_hudView addSubview:_preloadingSpinner];
    [_preloadingSpinner startAnimating];
    
    _hudCaption = [[UILabel alloc] initWithFrame:CGRectMake(0, captionY, boxSize, 22)];
    _hudCaption.backgroundColor = [UIColor clearColor];
    _hudCaption.textColor = [UIColor whiteColor];
    _hudCaption.adjustsFontSizeToFitWidth = YES;
    _hudCaption.textAlignment = UITextAlignmentCenter;
    _hudCaption.font=[_hudCaption.font fontWithSize:fontSize];
    _hudCaption.text = @"Loading...";
    [_hudView addSubview:_hudCaption];
    
    _hudView.center = presentingController.view.center;
    
    [presentingController.view addSubview:_hudView];
}

- (void)hideLoadingOverlay {
    if (_hudView) {
        [_hudView removeFromSuperview];
    }
    [_hudCaption release]; _hudCaption = nil;
    [_preloadingSpinner release]; _preloadingSpinner = nil;
    [_hudView release]; _hudView = nil;
}


- (BOOL)cancelPendingAnimations {
    BOOL animating = [[UIApplication sharedApplication] isIgnoringInteractionEvents];
    if(animating) {
        [theControllerToPresent.view.layer removeAllAnimations];
    }
    return animating;
}


- (void)showFullscreenBrowser {
    [self showFullscreenBrowserAnimated:YES];
}

- (void)showFullscreenBrowserAnimated:(BOOL)animated {
    if (!_isShowing) {
        [self hideStatusBar];

        if(!self.presentingController) {
            UIWindow* window = [UIApplication sharedApplication].keyWindow;
            self.presentingController = window.rootViewController;
        }
        
        //        [container setModalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
        
//        TILog(@"showFullscreenBrowserAnimated");
//        [self.presentingController presentViewController:self animated:animated completion:nil];
        [self.presentingController presentModalViewController:theControllerToPresent animated:animated];
        [self hideLoadingOverlay];
        _isShowing = YES;
    }
}

- (void)closeFullscreenBrowserAnimated:(BOOL)animated {
    [self closeFullscreenBrowserAnimated:animated completion:^{
        self.presentingController = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerDismissed:)]) {
            [self.delegate browserControllerDismissed:self];
        }
    }];
}

- (void)closeFullscreenBrowserAnimated:(BOOL)animated completion:(void(^)())completionBlock {
    void (^closeWhenReady)();
    
    closeWhenReady = ^(void){
        [self resetStatusBar];
        
        [_webView stopLoading];
        _webView.delegate = nil;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerWillDismiss:)]) {
            [self.delegate browserControllerWillDismiss:self];
        }
        
        if ([self.presentingController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
            // iOS 5 and above
            [self _modernCloseFullscreenBrowserAnimated:animated completion:completionBlock];
        }
        else {
            // for iOS < 5.0
            [self _legacyCloseFullscreenBrowserAnimated:animated completion:completionBlock];
        }
    };
    
    BOOL wasAnimating = [self cancelPendingAnimations];
    
    if (!wasAnimating) {
        closeWhenReady();
    }
    else {
        int64_t delayInMillis = 50.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMillis * NSEC_PER_MSEC);
        dispatch_after(popTime, dispatch_get_main_queue(), closeWhenReady);
    }
}

- (void)_modernCloseFullscreenBrowserAnimated:(BOOL)animated completion:(void(^)())completionBlock {
    [self.presentingController dismissViewControllerAnimated:animated completion:^{
        if (completionBlock) {
            completionBlock();
        }
    }];
}

- (void)_legacyCloseFullscreenBrowserAnimated:(BOOL)animated completion:(void(^)())completionBlock {
    [self.presentingController dismissModalViewControllerAnimated:animated];
    if (completionBlock) {
        // poll to see when close is done, then fire the completion block
        void (^closeWhenReady)();
        void (^__block __unsafe_unretained closeWhenReady_Recursive)();
        closeWhenReady_Recursive = closeWhenReady = [^(void) {
            if([[UIApplication sharedApplication] isIgnoringInteractionEvents]==TRUE) {
                int64_t delayInMillis = 50.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInMillis * NSEC_PER_MSEC);
                dispatch_after(popTime, dispatch_get_main_queue(), closeWhenReady_Recursive);
                [self cancelPendingAnimations];
                return;
            }
            
            completionBlock();
        } copy]; // close of block scope
        closeWhenReady();
        [closeWhenReady release];
    }
}

- (void)buildUI {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.view.frame = screenRect;
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(screenRect.origin.x, screenRect.origin.y, screenRect.size.width, screenRect.size.height-44)];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    
    _spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
    [_spinner sizeToFit];
    _spinner.hidesWhenStopped = YES;
    
    _backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back)];
    _backButton.enabled = YES;
    _backButton.imageInsets = UIEdgeInsetsZero;
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forward)];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    UIBarButtonItem *spacer3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _safariButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(safari)];
    UIBarButtonItem *spacer4 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _spinnerItem = [[UIBarButtonItem alloc] initWithCustomView:_spinner];
    UIBarButtonItem *spacer5 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    _doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(done)];
    _doneButton.style = UIBarButtonItemStyleDone;
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    NSMutableArray *items = [[NSMutableArray alloc] init];
    [items addObject:_backButton];
    [items addObject:[spacer1 autorelease]];
    [items addObject:_forwardButton];
    [items addObject:[spacer2 autorelease]];
    [items addObject:_refreshButton];
    [items addObject:[spacer3 autorelease]];
    [items addObject:_safariButton];
    [items addObject:[spacer4 autorelease]];
    [items addObject:_spinnerItem];
    [items addObject:[spacer5 autorelease]];
    [items addObject:_doneButton];
    toolbar.items = items;
    [items release];
    [self.view addSubview:toolbar];
    [toolbar release];
    
    [self.view addSubview:_webView];
}

#pragma mark -
#pragma mark Navigation actions

- (void)done 
{
    [self closeFullscreenBrowserAnimated:YES];
}

- (void)refresh 
{
	[_webView reload];
}

- (void)back 
{
	[_webView goBack];
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
}

- (void)forward 
{
	[_webView goForward];
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
}

- (void)safari
{
    _actionSheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                  destructiveButtonTitle:nil 
                                       otherButtonTitles:@"Open in Safari", nil] 
                    autorelease];
    [_actionSheet showFromBarButtonItem:_safariButton animated:YES];
}	

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	if (buttonIndex == 0) 
	{
        if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerShouldLoad:willLeaveApp:)]) {
            [self.delegate browserControllerShouldLoad:self willLeaveApp:YES];
        }
		// Open in Safari.
        [self closeFullscreenBrowserAnimated:NO];
        [[UIApplication sharedApplication] openURL:_webView.request.URL];
	}
    _actionSheet = nil;
}


#pragma mark -

- (BOOL)shouldLeaveAppToServeRequest:(NSURLRequest *)request {
    /*
     Should leave app if:
      - url is not http or https
      - hostname is in list of external apps
     */
    NSURL *theUrl = request.URL;
    if (![BROWSER_SCHEMES containsObject:theUrl.scheme] || [SPECIAL_HOSTS containsObject:theUrl.host]) {
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark UIWebViewDelegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
    TILog(@"webView:shouldStartLoadWithRequest:navigationType: %@", request);
    BOOL shouldProceed = YES;

    if (url) {
        [url release]; url = nil;
    }
    url = [request.URL retain];

#ifndef DISABLE_NEW_FEATURES
    NSNumber *appIdentifier = [self appIdentifierFromStoreUrl:request.URL];
    if (appIdentifier) {
        [self resetStatusBar];
        // show interalStore
        [self loadInAppStoreForApp:(NSNumber *)appIdentifier];
        // stop the request
        shouldProceed = NO; // url handled by system, nothing more to do here...
    }
    else
#endif
    if ([self shouldLeaveAppToServeRequest:request]) {
        // yield to OS
        [self hideLoadingOverlay];
        [self resetStatusBar];

        if ([[UIApplication sharedApplication] canOpenURL:request.URL]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
                [self.delegate browserControllerLoaded:self willLeaveApp:YES];
            }
            [self closeFullscreenBrowserAnimated:NO];
            [[UIApplication sharedApplication] openURL:request.URL];
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerFailedToLoad:withError:)]) {
                NSString *errStr = [NSString stringWithFormat:@"Couldn't open URL: %@", request.URL.absoluteString];
                NSDictionary *details = [NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey];
                NSError *err = [NSError errorWithDomain:NSPOSIXErrorDomain code:500 userInfo:details];
                
                [self.delegate browserControllerFailedToLoad:self withError:err];
            }
        }
        // stop the request
        shouldProceed = NO; // url handled by system, nothing more to do here...
    }
    else {
        // noop - continue processing
    }
    
    return shouldProceed;
}

- (NSNumber *)appIdentifierFromStoreUrl:(NSURL *)storeUrl {
    NSNumber *retVal = nil;
    #ifndef DISABLE_NEW_FEATURES
        // example: https://itunes.apple.com/ua/app/dont-touch/id372842596?mt=8
        // alt example: itms-apps://itunes.apple.com/app/id559353119?mt=8
        BOOL isStoreLink = [@"itunes.apple.com" isEqualToString:storeUrl.host];

        if (isStoreLink && inAppStoreVCClass) {
            NSArray *components = [[storeUrl pathComponents] retain];
            for (NSString *frag in components) {
                if ([frag rangeOfString:@"id"].location == 0) {
                    NSInteger intId = [[frag substringFromIndex:2] integerValue];
                    retVal = [NSNumber numberWithInteger:intId];
                }
            }
            
            [components release];
        }
    #endif
    return retVal;
}



#ifndef DISABLE_NEW_FEATURES
-(void)loadInAppStoreForApp:(NSNumber *)appIdentifier {
    SKStoreProductViewController *store = [[inAppStoreVCClass alloc] init];
    store.delegate = (id<SKStoreProductViewControllerDelegate>)self;
    NSDictionary *params = @{@"id": appIdentifier}; // SKStoreProductParameterITunesItemIdentifier
    [store loadProductWithParameters:params completionBlock:^(BOOL wasSuccessful, NSError *error){
        
        if (wasSuccessful) {
            if (_isShowing) {
                [self buildAndShowLoadingOverlay];
                [self closeFullscreenBrowserAnimated:NO completion:^{
                    [theControllerToPresent release];
                    theControllerToPresent = nil;
                    _isShowing = NO;

                    theControllerToPresent = [store retain];

                    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
                        [self.delegate browserControllerLoaded:self willLeaveApp:NO];
                    }
                    else {
                        NSLog(@"SnakkBrowserControllerDelegate wasn't defined... couldn't show internal app store!");
                    }
                }];
            }
            else {
                // notify that we should display app store...
                theControllerToPresent = [store retain];

                if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
                    [self.delegate browserControllerLoaded:self willLeaveApp:NO];
                }
                else {
                    NSLog(@"SnakkBrowserControllerDelegate wasn't defined... couldn't show internal app store!");
                }
            }
        }
        else {
            [self.delegate browserControllerFailedToLoad:self withError:error];
        }
    }];
}

-(void)loadInAppStoreForApp_OLD:(NSNumber *)appIdentifier {
    SKStoreProductViewController *store = [[inAppStoreVCClass alloc] init];
    store.delegate = (id<SKStoreProductViewControllerDelegate>)self;
    NSDictionary *params = @{@"id": appIdentifier}; // SKStoreProductParameterITunesItemIdentifier
    [store loadProductWithParameters:params completionBlock:^(BOOL wasSuccessful, NSError *error){
        
        if (wasSuccessful) {
            if (_isShowing) {
                // internal browser is already showing, close it first
                [self closeFullscreenBrowserAnimated:NO completion:^{
                    [self buildAndShowLoadingOverlay];
                    [theControllerToPresent release];
                    theControllerToPresent = nil;
                    _isShowing = NO;
                    
                    //                    myBlock(presentingController);
                    theControllerToPresent = [store retain];
                    
                    [presentingController dismissViewControllerAnimated:NO completion:^{
                        if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
                            [self.delegate browserControllerLoaded:self willLeaveApp:NO];
                        }
                        else {
                            NSLog(@"SnakkBrowserControllerDelegate wasn't defined... couldn't show internal app store!");
                        }
                    }];
                }];
            }
            else {
                //                myBlock(presentingController);
                theControllerToPresent = [store retain];
                
                [self.presentingController dismissViewControllerAnimated:NO completion:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
                        [self.delegate browserControllerLoaded:self willLeaveApp:NO];
                    }
                    else {
                        NSLog(@"SnakkBrowserControllerDelegate wasn't defined... couldn't show internal app store!");
                    }
                }];
            }
        }
        else {
            [self.delegate browserControllerFailedToLoad:self withError:error];
        }
    }];
}

-(void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    TILog(@"time to dismiss the store controller");

    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerWillDismiss:)]) {
        [self.delegate browserControllerWillDismiss:self];
    }
    
    [viewController dismissViewControllerAnimated:YES completion:nil];
    self.presentingController = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerDismissed:)]) {
        [self.delegate browserControllerDismissed:self];
    }
}
#endif

- (void)webViewDidStartLoad:(UIWebView *)webView 
{
	_refreshButton.enabled = YES;
	_safariButton.enabled = YES;
	[_spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
//    TILog(@"Finished loading %@", webView.request);
	_refreshButton.enabled = YES;
	_safariButton.enabled = YES;	
	_backButton.enabled = _webView.canGoBack;
	_forwardButton.enabled = _webView.canGoForward;
	[_spinner stopAnimating];
    
    BOOL willLeaveApp = NO;
    //TODO this fires for each redirect... we only want to fire on the final page
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerLoaded:willLeaveApp:)]) {
        [self.delegate browserControllerLoaded:(SnakkBrowserController *)self willLeaveApp:(BOOL)willLeaveApp];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled) {
        return;        
    }
    
    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(browserControllerFailedToLoad:withError:)]) {
        [self.delegate browserControllerFailedToLoad:self withError:error];
    }
}

- (void)dealloc {
    [_webView stopLoading];
    _webView.delegate = nil;
    [_webView release]; _webView = nil;
	[_backButton release]; _backButton = nil;
	[_forwardButton release]; _forwardButton = nil;
	[_refreshButton release]; _refreshButton = nil;
	[_safariButton release]; _safariButton = nil;
	[_doneButton release]; _doneButton = nil;
	[_spinner release]; _spinner = nil;
	[_spinnerItem release]; _spinnerItem = nil;
	[_actionSheet release]; _actionSheet = nil;
    [url release]; url = nil;
    [theControllerToPresent release]; theControllerToPresent = nil;
    [_hudCaption release]; _hudCaption = nil;
    [_preloadingSpinner release]; _preloadingSpinner = nil;
    [_hudView release]; _hudView = nil;
    
//    self.delegate = nil;

    [super dealloc];
}
@end
