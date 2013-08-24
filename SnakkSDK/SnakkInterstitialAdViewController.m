//
//  SnakkInterstitialAdViewController.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "SnakkInterstitialAdViewController.h"
#import "SnakkBrowserController.h"
#import "SnakkAdView.h"

@interface SnakkInterstitialAdViewController ()
@end

@implementation SnakkInterstitialAdViewController {
    UIActivityIndicatorView *loadingSpinner;
}

@synthesize animated, autoReposition, adView, snakkDelegate, closeButton, tappedURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.closeButton = nil;
        loadingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [loadingSpinner sizeToFit];
        loadingSpinner.hidesWhenStopped = YES;
        self.autoReposition = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.adView setCenter:self.view.center];
    [self.view addSubview:(UIView *)self.adView];
    self.view.backgroundColor = [UIColor blackColor];
    
  //  [self repositionToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    //stop-gap fix for ads getting pushed above the top of the screen.
    if (self.adView.frame.origin.y < 0)
        self.adView.frame = CGRectOffset(self.adView.frame, 0, -self.adView.frame.origin.y);
}




- (void)showCloseButton {
    if (!self.closeButton) {
        
        UIImage *closeButtonBackground = [UIImage imageNamed:@"Snakk.bundle/interstitial_close_button.png"];
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        self.closeButton.imageView.contentMode = UIViewContentModeCenter;
        [self.closeButton setImage:closeButtonBackground forState:UIControlStateNormal];
        
        [self.closeButton addTarget:self action:@selector(closeTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.adView.superview addSubview:self.closeButton];
        self.closeButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        
        CGRect appFrame = SnakkApplicationFrame(SnakkInterfaceOrientation());
        self.closeButton.frame = CGRectMake(appFrame.size.width - 50, 0, 50, 50);
    }
    
    [self.adView bringSubviewToFront:self.closeButton];
}

- (void)hideCloseButton {
    if (!self.closeButton) {
        return;
    }
    [self.closeButton removeFromSuperview];
    self.closeButton = nil;
}

- (void)closeTapped:(id)sender {
    id<SnakkInterstitialAdDelegate> tDel = [self.snakkDelegate retain];
    [tDel snakkInterstitialAdActionWillFinish:nil];
    [self dismissViewControllerAnimated:self.animated completion:^{
        [tDel snakkInterstitialAdActionDidFinish:nil];
        [tDel snakkInterstitialAdDidUnload:nil];
        [tDel release];
    }];
}

- (void)viewDidUnload
{
    self.closeButton = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)showLoading {
    loadingSpinner.center = self.view.center;
    [self.view addSubview:loadingSpinner];
    [loadingSpinner startAnimating];
}

- (void)hideLoading {
    [loadingSpinner stopAnimating];
    [loadingSpinner removeFromSuperview];
}



#pragma mark -
#pragma mark Orientation code

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self repositionToInterfaceOrientation:toInterfaceOrientation];
}

- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (!self.autoReposition) {
        return;
    }
    
    CGRect frame = SnakkApplicationFrame(orientation);

    CGFloat x = 0, y = 0;
    CGFloat w = self.adView.frame.size.width, h = self.adView.frame.size.height;
    
    x = frame.size.width/2 - self.adView.frame.size.width/2;
    y = frame.size.height/2 - self.adView.frame.size.height/2;
    
    //stop-gap fix for ads getting pushed above the top of the screen.
    if (y < 0)
        y = 0;
    
    self.adView.center = self.view.center;
    
    if(self.animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.adView setFrame:CGRectMake(x, y, w, h)];
        }
                         completion:^(BOOL finished){}
         ];
    }
    else {
        [self.adView setFrame:CGRectMake(x, y, w, h)];
    }
}


#pragma mark -

- (void)dealloc
{
    self.adView = nil;
    self.closeButton = nil;
    self.tappedURL = nil;
    [super dealloc];
}

@end
