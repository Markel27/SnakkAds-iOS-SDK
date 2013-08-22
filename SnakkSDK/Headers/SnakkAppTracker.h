//
//  SnakkAppTracker.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface SnakkAppTracker : NSObject

+ (SnakkAppTracker *)sharedAppTracker;

- (NSString *)deviceIFA;
- (NSInteger)advertisingTrackingEnabled;
- (NSString *)deviceUDID;
- (NSString *)userAgent;
- (CLLocation *)location;
- (NSInteger)networkConnectionType;
- (NSString *)carrier;
- (NSString *)carrierId;

- (void)reportApplicationOpen;

@end
