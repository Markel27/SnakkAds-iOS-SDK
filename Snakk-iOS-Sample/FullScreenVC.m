//
//  FullScreenVC.m
//  Snakk-iOS-Sample
//
//  View controller for full-screen ad view.
//
//  Created by Snakk Media on 8/22/2013.
//

#import "FullScreenVC.h"

@interface FullScreenVC ()

@end

@implementation FullScreenVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Full-screen landscape only
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

- (NSUInteger)supportedInterfaceOrientations
{   
    // Full-screen landscape only
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    
    // return NO when device orientation and status bar orientation don't match
    // so that setStatusBarOrientation would take effect.
    if (!UIDeviceOrientationIsLandscape(deviceOrientation) && !UIInterfaceOrientationIsPortrait(statusBarOrientation)) {
        return NO;
    }
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
