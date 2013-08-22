//
//  TVASTClickTrackingUIView.h
//  Snakk Rich Meda Ads SDK
//
//  Created by Snakk Media on 8/22/2013.
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//
//  Declares TVASTClickTrackingUIView instance that is set to track clicks on the
//  ad. Also defines a delegate protocol for click tracking view to get
//  clicks from the view.
//

#import <UIKit/UIKit.h>

#pragma mark TVASTClickTrackingUIViewDelegate

@class TVASTClickTrackingUIView;

/// Delegate protocol for TVASTClickTrackingUIView.
//
/// The publisher can adopt this protocol to receive touch events from the
/// TVASTClickTrackingUIView instance.
@protocol TVASTClickTrackingUIViewDelegate

 @required
/// Received when the user touched the click tracking view.
- (void)clickTrackingView:(TVASTClickTrackingUIView *)view
    didReceiveTouchEvent:(UIEvent *)event;

@end

#pragma mark -

/// A UIView instance that is used as the click tracking element.
//
/// In order for the SDK to track clicks on the ad, a transparent click tracking
/// should be added on the video player and should be added as the tracking
/// element by setting click tracking view on TVASTVideoAdsManager.
@interface TVASTClickTrackingUIView : UIView <UIGestureRecognizerDelegate>

/// Delegate object that receives touch notifications.
//
/// The caller should implement TVASTClickTrackingUIViewDelegate to get touch
/// events from the view. Remember to nil the delegate before deallocating
/// this object.
@property (nonatomic, assign) id<TVASTClickTrackingUIViewDelegate> delegate;

@end
