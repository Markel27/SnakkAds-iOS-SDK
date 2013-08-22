//
//  AdPromptDemoController.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SnakkAdDelegates.h"

@class SnakkAdPrompt;

@interface AdPromptDemoController : UIViewController <SnakkAdPromptDelegate> {
    SnakkAdPrompt *snakkAdPrompt;
}

//@property (retain, nonatomic) CLLocationManager *locationManager;

@property (retain, nonatomic) IBOutlet UIButton *preloadButton;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

-(IBAction)preLoadAdPrompt:(id)sender;
-(IBAction)showAdPrompt:(id)sender;
-(IBAction)simpleExample:(id)sender;

@end
