//
//  VideoAdController.h
//  Snakk-iOS-Sample
//
//  Sample view controller showcasing Snakk's Video Ad SDK.
//
//  Created by Snakk Media on 8/22/2013.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CMTime.h>
#import <UIKit/UIKit.h>

#import "TVASTAdsRequest.h"
#import "TVASTVideoAdsManager.h"
#import "TVASTAdsLoader.h"
#import "TVASTClickTrackingUIView.h"
#import "TVASTClickThroughBrowser.h"

#import "FullScreenVC.h"

@interface VideoAdController : UIViewController<TVASTAdsLoaderDelegate,
            TVASTClickTrackingUIViewDelegate, TVASTVideoAdsManagerDelegate,
            TVASTClickThroughBrowserDelegate>

// The loader of ads.
@property(nonatomic, retain) TVASTAdsLoader *adsLoader;
// The manager of video ads.
@property(nonatomic, retain) TVASTVideoAdsManager *videoAdsManager;
// The invisible view that tracks clicks on the video.
@property(nonatomic, retain) TVASTClickTrackingUIView *clickTrackingView;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) AVPlayer              *contentPlayer;
@property (nonatomic, retain) AVPlayer              *adPlayer;
@property (nonatomic, retain) AVPlayer              *playingPlayer;
@property (nonatomic, retain) UIView                *adView;
@property (nonatomic, assign) id                    playHeadObserver;
@property (nonatomic, assign) BOOL                  isVideoSkippable;
@property (nonatomic, retain) FullScreenVC          *landscapeVC;
@property (nonatomic, retain) UIImage               *playButtonImage;
@property (nonatomic, retain) UIImage               *pauseButtonImage;

@property (nonatomic, retain) IBOutlet UIButton     *adRequestButton;
@property (nonatomic, retain) IBOutlet UIButton     *resetButton;
@property (nonatomic, retain) IBOutlet UISwitch     *browserSwitch;
@property (nonatomic, retain) IBOutlet UIView       *videoView;
@property (nonatomic, retain) IBOutlet UIButton     *playHeadButton;
@property (nonatomic, retain) IBOutlet UITextField  *playTimeText;
@property (nonatomic, retain) IBOutlet UITextField  *durationText;
@property (nonatomic, retain) IBOutlet UISlider     *progressBar;
@property (nonatomic, retain) IBOutlet UITextView   *console;
@property (nonatomic, retain) IBOutlet UISwitch     *maximizeSwitch;

- (IBAction)onPlayPauseClicked:(id)sender;
- (IBAction)playHeadValueChanged:(id)sender;
- (IBAction)onRequestAds;
- (IBAction)onUnloadAds;
- (IBAction)onResetState;

@property (retain, nonatomic) IBOutlet UIView *controlsView;

@end
