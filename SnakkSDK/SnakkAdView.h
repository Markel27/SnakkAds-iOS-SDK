//
//  SnakkAdView.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakkAdManagerDelegate.h"
#import "SnakkMraidDelegate.h"

@class SnakkRequest;

@interface SnakkAdView : UIWebView <UIWebViewDelegate> {
}

@property (retain, nonatomic) SnakkRequest *snakkRequest;
@property (assign, nonatomic) id<SnakkAdManagerDelegate> snakkDelegate;
@property (assign, nonatomic) BOOL isLoaded;
@property (assign, nonatomic) BOOL interceptPageLoads;
@property (assign, nonatomic) BOOL isVisible;
@property (assign, nonatomic) BOOL wasAdActionShouldBeginMessageFired;

@property (assign, nonatomic) BOOL isMRAID;
@property (assign, nonatomic) id<SnakkMraidDelegate> mraidDelegate;
@property (retain, nonatomic) NSString *mraidState;

- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)setScrollable:(BOOL)scrollable;
//- (void)loadHTMLString:(NSString *)string;
- (void)loadData:(NSDictionary *)data;


//- (void)setIsVisible:(BOOL)visible;


- (void)syncMraidState;
- (void)fireMraidEvent:(NSString *)eventName withParams:(NSString *)jsonString;

@end
