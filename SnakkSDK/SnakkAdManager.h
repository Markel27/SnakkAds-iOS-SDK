//
//  SnakkAdManager.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakkAdView.h"
#import "snakkAdDelegates.h"
#import "SnakkAdManagerDelegate.h"

@class SnakkRequest;


@interface SnakkAdManager : NSObject <SnakkAdManagerDelegate>

@property (assign, nonatomic) id<SnakkAdManagerDelegate> delegate;
@property (copy, nonatomic) NSDictionary *params;
@property (retain, nonatomic) NSURLConnection *currentConnection;
@property (retain, nonatomic) SnakkRequest *currentRequest;

- (void)fireAdRequest:(SnakkRequest *)request;
- (void)cancelAdRequests;

@end
