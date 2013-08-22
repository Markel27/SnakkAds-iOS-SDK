//
//  TVASTVideoAdsManager.h
//  Snakk Rich Meda Ads SDK
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//
//  Declares TVASTVideoAdsManager interface that manages playing and unloading
//  video ads.

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TVASTAdError.h"
#import "TVASTClickTrackingUIView.h"

/// Supported AdsManager Types
typedef enum {
    kTVASTAdsManagerTypeVideo,
} TVASTAdsManagerType;

@class TVASTVideoAdsManager;

/// Delegate object that gets state change callbacks from TVASTVideoAdsManager.
@protocol TVASTVideoAdsManagerDelegate<NSObject>

/// Called when content should be paused. This usually happens right before a
/// an ad is about to cover the content.
- (void)contentPauseRequested:(TVASTVideoAdsManager *)adsManager;

/// Called when content should be resumed. This usually happens when ad ad
/// finishes or collapses.
- (void)contentResumeRequested:(TVASTVideoAdsManager *)adsManager;

@optional
/// Called when an error occured while loading or playing the ad.
- (void)didReportAdError:(TVASTAdError *)error;

@end

#pragma mark -
#pragma mark TVASTVastEventNotifications

/// Start Vast event broadcasted by the ads manager.
//
/// This happens when video ad starts to play.
extern NSString * const TVASTVastEventStartNotification;

/// First quartile Vast event broadcasted by the ads manager.
//
/// This happens when ad crosses first quartile boundary.
extern NSString * const TVASTVastEventFirstQuartileNotification;

/// Midpoint Vast event broadcasted by the ads manager.
//
/// This happens when ad crosses midpoint boundary.
extern NSString * const TVASTVastEventMidpointNotification;

/// Third quartile Vast event broadcasted by the ads manager.
//
/// This happens when ad crosses third quartile boundary.
extern NSString * const TVASTVastEventThirdQuartileNotification;

/// Complete Vast event broadcasted by the ads manager.
//
/// This happens when video ad completes playing successfully.
extern NSString * const TVASTVastEventCompleteNotification;

/// Pause Vast event broadcasted by the Video ads manager.
//
/// This happens when video ad pauses.
extern NSString * const TVASTVastEventPauseNotification;

/// Click event broadcasted by the Video ads manager.
//
/// This happens when user clicks on the click tracking element overlayed on
/// the video ad.
extern NSString * const TVASTVastEventClickNotification;

/// Rewind event broadcasted by the Video ads manager.
//
/// This happens when user rewinds the video ad.
extern NSString * const TVASTVastEventRewindNotification;

/// \memberof TVASTVideoAdsManager
/// Skip event broadcast by the Video ads manager.
//
/// This happens when user skips the current ad.
extern NSString * const TVASTVastEventSkipNotification;

/// Impression broadcast by the Video ads manager.
//
extern NSString * const TVASTVastImpressionNotification;

/// Linear ad createevent broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventCreativeViewNotification;

/// Linear ad error event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventLinearErrorNotification;

/// Linear ad mute event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventMuteNotification;

/// Linear ad unmute event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventUnmuteNotification;

/// Linear ad resume event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventResumeNotification;

/// Linear ad fullscreen event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventFullscreenNotification;

/// Linear ad expand event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventExpandNotification;

/// Linear ad collapse event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventCollapseNotification;

/// Linear ad accept invitation event broadcast by the Video ads manager.
//
extern NSString * const TVASTVastEventAcceptInvitationLinearNotification;

extern NSString * const TVASTVastEventAcceptInvitationNotification;

extern NSString * const TVASTVastEventCloseNotification;

extern NSString * const TVASTVastEventCloseLinearNotification;

#pragma mark -

/// The TVASTVideoAdsManager class is responsible for playing video ads.
@interface TVASTVideoAdsManager : NSObject <UIGestureRecognizerDelegate>

/// Stops playing the ad and unloads the ad asset.
//
/// Removes ad assets at runtime that need to be properly removed at the time
/// of ad completion amd stops the ad and removes tracking.
- (void)unload;

/// Returns the AdsManager type.
@property(readonly, assign) TVASTAdsManagerType adsManagerType;

/// List of ads managed by the ads manager.
@property(readonly, retain) NSArray *ads;


/// Play the loaded ad in the provided |player|.
//
/// The caller should implement TVASTVideoAdsManagerDelegate and set the delegate
/// before calling this method so the SDK can send notifications about state
/// changes that require player attention.

- (void)playWithAVPlayer:(AVPlayer *)player;

/// Sets the click tracking view which will tracks clicks on the player.
//
/// Click tracking must be enabled on the video player area before the ad can be
/// played. Create an instance that is of type TVASTClickTrackingUIView and set it
/// as a transparent view on top of the video player. If this is not set clicks
/// will not be tracked by the SDK.
@property(nonatomic, retain) TVASTClickTrackingUIView *clickTrackingView;

@property(nonatomic, assign) BOOL showFullScreenAd;

/// Delegate object that receives state change notifications.
//
/// The caller should implement TVASTVideoAdsManagerDelegate to get state change
/// notifications from the ads manager. Remember to nil the delegate before
/// deallocating this object.
@property(nonatomic, assign) NSObject<TVASTVideoAdsManagerDelegate> *delegate;

@end
