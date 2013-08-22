//
//  VideoAdController.m
//  Snakk-iOS-Sample
//
//  Sample view controller showcasing Snakk's Video Ad SDK.
//
//  Created by Snakk Media on 8/22/2013.
//

#import "VideoAdController.h"
#import "TVASTAd.h"
#import "BackgroundHelper.h"

@interface VideoAdController ()

-(IBAction) browserSwitchChanged:(id)sender;
-(IBAction) maximizeSwitchChanged:(id)sender;

// Utility methods
- (void)logMessage:(NSString *)log, ...;
- (void)clearLog;

// Init the content player.
- (void)setUpContentPlayer;

// Init the ad player.
- (void)setUpAdPlayer;

// Switch between the content player and ad player.
- (void)switchPlayheadObserverTo:(AVPlayer *)toPlayer;

- (void)updatePlayHeadTime:(CMTime)time;

- (void)updatePlayHeadDuration;

- (void)updatePlayHeadState:(BOOL)isPlaying;

- (void)setUpAdsLoader;

- (void)unloadAdsManager;

@end

@implementation VideoAdController

@synthesize adRequestButton = _adRequestButton;
@synthesize resetButton     = _resetButton;
@synthesize browserSwitch   = _browserSwitch;
@synthesize videoView       = _videoView;
@synthesize playHeadButton  = _playHeadButton;
@synthesize playTimeText    = _playTimeText;
@synthesize durationText    = _durationText;
@synthesize progressBar     = _progressBar;
@synthesize console         = _console;

@synthesize playButtonImage = _playButtonImage;
@synthesize pauseButtonImage= _pauseButtonImage;
@synthesize contentPlayer   = _contentPlayer;
@synthesize adPlayer        = _adPlayer;
@synthesize playingPlayer   = _playingPlayer;
@synthesize adView          = _adView;
@synthesize playHeadObserver= _playHeadObserver;
@synthesize isVideoSkippable= _isVideoSkippable;
@synthesize adsLoader       = _adsLoader;
@synthesize videoAdsManager = _videoAdsManager;
@synthesize clickTrackingView=_clickTrackingView;
@synthesize landscapeVC     = _landscapeVC;

//*************************************
// Replace with your valid ZoneId here.
NSString *const kZoneId         = @"31377";     //@"24839";     //@"22219";

// For Testing Purpose Only.
NSString *const kTestCreativeId = @"130902";    //@"137902";    //@"128681";

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundleOrNil
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        self = [super initWithNibName:[NSString stringWithFormat:@"%@_iPad", nibName] bundle:nibBundleOrNil];
    else
        self = [super initWithNibName:[NSString stringWithFormat:@"%@_iPhone", nibName] bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [_clickTrackingView setDelegate:nil];
    [_clickTrackingView release];
    [_playButtonImage release];
    [_pauseButtonImage release];
    [_adsLoader release];
    [_contentPlayer release];
    [_adPlayer release];
    [_playingPlayer release];
    [_landscapeVC release];
    [_adView release];
    
    [_adRequestButton release];
    [_resetButton release];
    [_maximizeSwitch release];
    [_browserSwitch release];
    [_videoView release];
    [_playHeadButton release];
    [_playTimeText release];
    [_durationText release];
    [_progressBar release];
    [_console release];
    
    [_backgroundImageView release];
    [_controlsView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(CGRectGetHeight([UIScreen mainScreen].bounds) == 568) {
        //iphone 5
        CGRect frame = _console.frame;
        frame.size.height += 88;    
        _console.frame = frame;
    }
    
    [_console.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [_console.layer setBorderWidth:2.0];
    else {
        [_console.layer setBorderWidth:1.0];
    }
    
    self.playButtonImage = [UIImage imageNamed:@"play.png"];
    self.pauseButtonImage = [UIImage imageNamed:@"pause.png"];
    
    [_playHeadButton setImage:_playButtonImage forState:UIControlStateNormal];
    _videoView.backgroundColor = [UIColor blackColor];

    [self setUpContentPlayer];
    [self setUpAdPlayer];
    [self setUpAdsLoader];
    
    [self logMessage:@"SDK Version: %@", [TVASTAd getSDKVersionString]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
    [self updateControlFrame];
}

- (void)setUpContentPlayer {

    NSString *fileURL = [[NSBundle mainBundle] pathForResource:@"disneyplaneslowbitrate" ofType:@"m4v"];
    NSURL *assetUrl = [NSURL fileURLWithPath:fileURL];

    AVAsset *contentAsset = [AVURLAsset URLAssetWithURL:assetUrl options:0];
    AVPlayerItem *contentPlayerItem = [AVPlayerItem playerItemWithAsset:contentAsset];
    self.contentPlayer = [AVPlayer playerWithPlayerItem:contentPlayerItem];
    AVPlayerLayer *avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_contentPlayer];
    avPlayerLayer.frame = _videoView.layer.bounds;
    [_videoView.layer addSublayer:avPlayerLayer];
    [self switchPlayheadObserverTo:_contentPlayer];
    
    _isVideoSkippable = YES;

    CGRect videoFrame = _videoView.frame;
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(videoFrame), CGRectGetHeight(videoFrame));
    
    // Create a click tracking view
    self.clickTrackingView = [[[TVASTClickTrackingUIView alloc] initWithFrame:frame] autorelease];
    [_clickTrackingView setDelegate:self];
}

// Set up Ad Player but don't add it to the video view.
- (void)setUpAdPlayer {
    self.adPlayer = [[[AVPlayer alloc] init] autorelease];

    AVPlayerLayer *adPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_adPlayer];
    [adPlayerLayer setName:@"AdPlayerLayer"];
    
    if (![_maximizeSwitch isOn]) {
        self.landscapeVC = nil;
        
        CGRect videoFrame = _videoView.frame;
        CGRect frame = CGRectMake(0, 0, CGRectGetWidth(videoFrame), CGRectGetHeight(videoFrame));
        self.adView = [[[UIView alloc] initWithFrame:frame] autorelease];
        _adView.backgroundColor = [UIColor whiteColor];
        _adView.hidden = YES;
        adPlayerLayer.frame = _adView.layer.bounds;
        [_adView.layer addSublayer:adPlayerLayer];

        _clickTrackingView.frame = frame;
        [_videoView addSubview:_clickTrackingView];
    }
    else {
        self.adView = nil;
        
        NSString *nibName = [NSString stringWithFormat:@"FullScreenVC_%@",
                             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"iPad":@"iPhone"];
        self.landscapeVC = [[[FullScreenVC alloc] initWithNibName:nibName bundle:nil] autorelease];
        [_landscapeVC.view setHidden:YES];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGRect frame = CGRectMake(0, 0, CGRectGetHeight(window.frame), CGRectGetWidth(window.frame));
        adPlayerLayer.frame = frame;
        [_landscapeVC.view.layer addSublayer:adPlayerLayer];
        
        _clickTrackingView.frame = frame;
        [_landscapeVC.view addSubview:_clickTrackingView];
    }
}

- (void)switchPlayheadObserverTo:(AVPlayer *)toPlayer {
    [_playingPlayer removeTimeObserver:_playHeadObserver];
    // Create a playHead observer to get time updates from the player.
    self.playHeadObserver = [toPlayer
                             addPeriodicTimeObserverForInterval:CMTimeMake(1, 30)
                             queue:NULL
                             usingBlock:^(CMTime time) {
                                 [self updatePlayHeadTime:time];
                             }];
    [_playingPlayer removeObserver:self forKeyPath:@"rate"];
    [toPlayer addObserver:self
               forKeyPath:@"rate"
                  options:0
                  context:@"contentPlayerRate"];
    [_playingPlayer removeObserver:self forKeyPath:@"currentItem.duration"];
    [toPlayer addObserver:self
               forKeyPath:@"currentItem.duration"
                  options:0
                  context:@"playerDuration"];
    self.playingPlayer = toPlayer;
}


- (void)updatePlayHeadTime:(CMTime)time {
    if (CMTIME_IS_INVALID(time)) {
        return;
    }
    Float64 currentTime = CMTimeGetSeconds(time);
    if (isnan(currentTime)) {
        return;
    }
    _progressBar.value = currentTime;
    _playTimeText.text = [NSString stringWithFormat:@"%d.%02d",
                            (int)currentTime / 60,
                            (int)currentTime % 60];
    [self updatePlayHeadDuration];
}

- (CMTime)getPlayerItemDuration:(AVPlayerItem *)item {
    CMTime itemDuration = kCMTimeInvalid;
    if ([item respondsToSelector:@selector(duration)]) {
        itemDuration = item.duration;
    }
    else {
        if (item.asset &&
            [item.asset respondsToSelector:@selector(duration)]) {
            // Sometimes the test app hangs here for ios 4.2.
            itemDuration = item.asset.duration;
        }
    }
    return itemDuration;
}

- (void)updatePlayHeadDuration {
    CMTime durationCMTime = [self getPlayerItemDuration:_playingPlayer.currentItem];
    if (CMTIME_IS_INVALID(durationCMTime)) {
        return;
    }
    Float64 duration = CMTimeGetSeconds(durationCMTime);
    
    if (isnan(duration)) {
        return;
    }
    _progressBar.maximumValue = duration;
    
    // could only display 19:59 max.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        duration = (int)duration % 1200;  
    
    _durationText.text = [NSString stringWithFormat:@"%d.%02d",
                            (int)duration / 60,
                            (int)duration % 60];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == @"contentPlayerRate" && _playingPlayer == object) {
        [self updatePlayHeadState:(_playingPlayer.rate != 0)];
    }
    else if (context == @"playerDuration" && _playingPlayer == object) {
        [self updatePlayHeadDuration];
    }
}

- (void)updatePlayHeadState:(BOOL)isPlaying {
    if (isPlaying) {
        _playHeadButton.tag = 1;
        [_playHeadButton setImage:_pauseButtonImage forState:UIControlStateNormal];
    } else {
        _playHeadButton.tag = 0;
        [_playHeadButton setImage:_playButtonImage forState:UIControlStateNormal];
    }
}

- (void)logMessage:(NSString *)log, ...{
    va_list args;
    va_start(args, log);
    NSString *s = [[[NSString alloc] initWithFormat:log arguments:args] autorelease];
    _console.text = [_console.text stringByAppendingString:s];
    [_console scrollRangeToVisible:NSMakeRange(self.console.text.length-20, 20)];
    va_end(args);
}

- (void)clearLog {
    _console.text = @"";
}

- (void)setUpAdsLoader {
    self.adsLoader = [[[TVASTAdsLoader alloc] init] autorelease];
    _adsLoader.delegate = self;
}

- (void)unloadAdsManager {
    if (_videoAdsManager != nil) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_videoAdsManager unload];
        _videoAdsManager.delegate = nil;
        self.videoAdsManager = nil;
    }
}

#pragma mark UIOutlet method implementations

-(IBAction) maximizeSwitchChanged:(id)sender {
    [self setUpAdPlayer];
}

-(IBAction) browserSwitchChanged:(id)sender {
    if ([_browserSwitch isOn]) {
        [TVASTClickThroughBrowser enableInAppBrowserWithViewController:self
                                                             delegate:self];
    }
    else {
        [TVASTClickThroughBrowser disableInAppBrowser];
    }
}

- (void)onRequestAds {
    [self logMessage:@"Requesting ads...\n"];
    [self unloadAdsManager];

    // Create an adsRequest object and request ads from the ad server.
    TVASTAdsRequest *request = [TVASTAdsRequest requestWithAdZone:kZoneId];
    [request setCustomParameter:kTestCreativeId forKey:@"cid"];
    [request setCustomParameter:@"preroll" forKey:@"videotype"];
    [_adsLoader requestAdsWithRequestObject:request];
    
    
}

- (void)onUnloadAds {
    [self logMessage:@"Unloading ads\n"];
    [self unloadAdsManager];
}

- (void)onResetState {
    [self unloadAdsManager];
    [_contentPlayer pause];
    [_contentPlayer seekToTime:CMTimeMake(0, 1)];
    [self updatePlayHeadState:NO];
    self.adsLoader = nil;
    [self setUpAdsLoader];
    [self clearLog];
}

- (void)playHeadValueChanged:(id)sender {
    if (![sender isKindOfClass:[UISlider class]]) {
        return;
    }
    UISlider *slider = (UISlider *)sender;

    if (_isVideoSkippable ||
        CMTimeCompare(_playingPlayer.currentTime, CMTimeMake(slider.value, 1)) > 0) {
        // skip to the point of content where the slider has changed to.
        [_playingPlayer seekToTime:CMTimeMake(slider.value, 1)];
    }
}

- (void)onPlayPauseClicked:(id)sender {
    if (![sender isKindOfClass:[UIButton class]] && sender != _playHeadButton) {
        return;
    }
    if (_playingPlayer.rate == 0)
        [_playingPlayer play];
    else
        [_playingPlayer pause];
}

#pragma mark -
#pragma mark Vast Event Notification implementation

// Get VAST event notifications from the ads manager.
- (void)didReceiveVastEvent:(NSNotification *)notification {
    [self logMessage:@"Received: %@\n", notification.name];
}

// Set the VAST event notification observer.
- (void)addObserverForVastEvent:(NSString *)vastEvent {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveVastEvent:)
                                                 name:vastEvent
                                               object:_videoAdsManager];
}

#pragma mark -
#pragma mark TVASTClickTrackingUIViewDelegate implementation

- (void)clickTrackingView:(TVASTClickTrackingUIView *)view didReceiveTouchEvent:(UIEvent *)event {
    [self logMessage:@"Ad view clicked on.\n"];
}

#pragma mark -
#pragma mark TVASTAdsLoaderDelegate implementation

// Sent when ads are successfully loaded from the ad servers
- (void)adsLoader:(TVASTAdsLoader *)loader adsLoadedWithData:(TVASTAdsLoadedData *)adsLoadedData {
    [self logMessage:@"Ads have been loaded.\n"];
    
    TVASTVideoAdsManager *adsManager = adsLoadedData.adsManager;

    if (adsManager) {
        self.videoAdsManager = adsManager;
        // Set delegate to receive callbacks.
        _videoAdsManager.delegate = self;
        // Set the click tracking view.
        _videoAdsManager.clickTrackingView = _clickTrackingView;

        if ([_browserSwitch isOn])
            [TVASTClickThroughBrowser enableInAppBrowserWithViewController:nil delegate:self];
        else
            [TVASTClickThroughBrowser disableInAppBrowser];

        // set show ad full-screen or not.
        _videoAdsManager.showFullScreenAd = ([_maximizeSwitch isOn]);
        
        // Add notification observer for all VAST events.
        [self addObserverForVastEvent:TVASTVastEventStartNotification];
        [self addObserverForVastEvent:TVASTVastEventFirstQuartileNotification];
        [self addObserverForVastEvent:TVASTVastEventMidpointNotification];
        [self addObserverForVastEvent:TVASTVastEventThirdQuartileNotification];
        [self addObserverForVastEvent:TVASTVastEventCompleteNotification];
        [self addObserverForVastEvent:TVASTVastEventClickNotification];
        [self addObserverForVastEvent:TVASTVastEventPauseNotification];
        [self addObserverForVastEvent:TVASTVastEventRewindNotification];
        [self addObserverForVastEvent:TVASTVastEventClickNotification];
        [self addObserverForVastEvent:TVASTVastEventSkipNotification];
        [self addObserverForVastEvent:TVASTVastEventCreativeViewNotification];
        [self addObserverForVastEvent:TVASTVastEventLinearErrorNotification];
        [self addObserverForVastEvent:TVASTVastEventMuteNotification];
        [self addObserverForVastEvent:TVASTVastEventUnmuteNotification];
        [self addObserverForVastEvent:TVASTVastEventResumeNotification];
        [self addObserverForVastEvent:TVASTVastEventFullscreenNotification];
        [self addObserverForVastEvent:TVASTVastEventExpandNotification];
        [self addObserverForVastEvent:TVASTVastEventCollapseNotification];
        [self addObserverForVastEvent:TVASTVastEventAcceptInvitationLinearNotification];
        [self addObserverForVastEvent:TVASTVastEventAcceptInvitationNotification];
        [self addObserverForVastEvent:TVASTVastEventCloseNotification];
        [self addObserverForVastEvent:TVASTVastEventCloseLinearNotification];
        
        // Tell the adsManager to play the ad.
        [_videoAdsManager playWithAVPlayer:_adPlayer];
        
        // Show a few attributes of one of the loaded ads
        TVASTAd *videoAd = [_videoAdsManager.ads objectAtIndex:0];
        [self logMessage: [NSString stringWithFormat:@"VideoAdType: %d\n", videoAd.adType]];
        [self logMessage: [NSString stringWithFormat:@"VideoAdId: %@\n", videoAd.adId]];
        [self logMessage: [NSString stringWithFormat:@"VideoAdUrl: %@\n", videoAd.mediaUrl]];
        [self logMessage: [NSString stringWithFormat:@"VideoAdDuration: %f\n", videoAd.duration]];
        [self logMessage: [NSString stringWithFormat:@"VideoAdHeight: %f\n", videoAd.creativeHeight]];
        [self logMessage: [NSString stringWithFormat:@"VideoAdWidth: %f\n", videoAd.creativeWidth]];
    }
}

// Set when ads loading failed.
- (void)adsLoader:(TVASTAdsLoader *)loader failedWithErrorData:(TVASTAdLoadingErrorData *)errorData {
    [self logMessage:@"Encountered Error: code:%d,message:%@\n", errorData.adError.code,
     [errorData.adError localizedDescription]];
}

#pragma mark -
#pragma mark TVASTClickThroughBrowserDelegate implementation

- (void)browserDidOpen {
    [self logMessage:@"In-app browser opened.\n"];
}

- (void)browserDidClose {
    [self logMessage:@"In-app browser closed.\n"];
}

#pragma mark -
#pragma mark TVASTVideoAdsManagerDelegate implementation

// Called when content should be paused. This usually happens right before a
// an ad is about to cover the content.
- (void)contentResumeRequested:(TVASTVideoAdsManager *)adsManager {
    [self logMessage:@"Content resume requested.\n"];
    
    // first, pause the ad player
    [_playingPlayer pause];
    _adView.hidden = YES;
    [self switchPlayheadObserverTo:_contentPlayer];
    
    if (![_maximizeSwitch isOn]) {
        [_adView removeFromSuperview];
    }
    else {
        [_landscapeVC dismissViewControllerAnimated:YES completion:^(){}];
        [_landscapeVC.view setHidden:YES];
    }
    
    // after the switch, resume the content player
    [_playingPlayer play];
    [self updatePlayHeadState:YES];
    
    // The content player is skippable when content is playing.
    _isVideoSkippable = YES;
    
    [self setUpAdPlayer];
    
    // unlock the maximized ad switch
    [_maximizeSwitch setEnabled:YES];
}

// Called when content should be resumed. This usually happens when an ad
// finishes or collapses.
- (void)contentPauseRequested:(TVASTVideoAdsManager *)adsManager {
    [self logMessage:@"Content pause requested.\n"];
    
    // first, pause the content player
    [_playingPlayer pause];
    [self switchPlayheadObserverTo:_adPlayer];
    
    // lock the maximized ad switch state until the content is resumed
    [_maximizeSwitch setEnabled:NO];
    
    if (![_maximizeSwitch isOn]) {
        _adView.hidden = NO;
        // add the ad view to the view stack.
        [_videoView insertSubview:_adView belowSubview:_clickTrackingView];
    }
    else {
        _landscapeVC.view.hidden = NO;
        // use appropriate undeficated method based on the iOS version
        if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0f)
            [self presentModalViewController:_landscapeVC animated:YES];
        else
            [self presentViewController:_landscapeVC animated:YES completion:^(){}];
    }
    [self updatePlayHeadState:NO];
    
    // The content player is not skippable when ad is playing.
    _isVideoSkippable = NO;
}

- (void)didReportAdError:(TVASTAdError *)error {
    [self logMessage:[NSString stringWithFormat:@"Error encountered while playing:%@\n.",
                      [error localizedDescription]]];
}

#pragma mark -

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewDidUnload {
    [self.playingPlayer pause];
    [self.clickTrackingView removeFromSuperview];
    [self.playingPlayer removeObserver:self forKeyPath:@"rate"];
    self.clickTrackingView.delegate = nil;
    self.clickTrackingView = nil;
    self.playButtonImage = nil;
    self.pauseButtonImage = nil;
    [self unloadAdsManager];
    self.adsLoader = nil;
    self.contentPlayer = nil;
    self.adPlayer = nil;
    self.playingPlayer = nil;
    [self.adView removeFromSuperview];
    [self.videoView removeFromSuperview];
    if ([[UIDevice currentDevice].systemVersion floatValue] < 5.0f)
        [self.landscapeVC dismissModalViewControllerAnimated:NO];
    else
        [self.landscapeVC dismissViewControllerAnimated:NO completion:^(){}];
    self.adView = nil;
    self.landscapeVC = nil;
    self.videoView = nil;
    self.playHeadButton = nil;
    self.playTimeText = nil;
    self.durationText = nil;
    self.progressBar = nil;
    self.adRequestButton = nil;
    self.resetButton = nil;
    self.maximizeSwitch = nil;
    self.browserSwitch = nil;
    [self setBackgroundImageView:nil];
    [self setControlsView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [BackgroundHelper updateBackgroundToOrientation:self.backgroundImageView];
    [self updateControlFrame];
}

-(void)updateControlFrame
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        if (screenRect.size.height != 1024.0f)
        {
            self.controlsView.frame = CGRectMake(0, 264, 320, 147);
        }
    }
    else
    {
        if (screenRect.size.height != 1024.0f)
        {
            self.controlsView.frame = CGRectMake(320, 0, 320, 147);
        }
    }
}

@end
