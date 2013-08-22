//
//  SnakkAdDelegates.h
//  Snakk iOS SDK
//
//  Copyright 2012 Snakk All rights reserved.
//
//

@class SnakkBannerAdView;

@protocol SnakkBannerAdViewDelegate <NSObject>
@optional

/**
 Called before a new banner advertisement is loaded.
 
 @param bannerView The banner view that is about to a new advertisement.
 */
- (void)snakkBannerAdViewWillLoadAd:(SnakkBannerAdView *)bannerView;

/**
 Called when a new banner advertisement is loaded.
 
 @param bannerView The banner view that loaded a new advertisement.
 */
- (void)snakkBannerAdViewDidLoadAd:(SnakkBannerAdView *)bannerView;

/**
 Called when a banner view fils to load a new advertisement.
 
 @param bannerView The banner view that failed to load an advertisement.
 @param error The error object that describes the problem.
 */
- (void)snakkBannerAdView:(SnakkBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error;

/**
 Called before a banner view executes an action.
 
 @param bannerView The banner view that the user tapped.
 @param willLeave YES if another application will be launched to execute the action; NO if the action is going to be executed inside your appliaction.
 
 @return Your delegate returns YES if the banner action should execute; NO to prevent the banner action from executing.
 
 This method is called when the user taps the banner view. Your application controls whether the action is triggered. To allow the action to be triggered, 
 return YES. To suppress the action, return NO. Your application should almost always allow actions to be triggered; preventing actions may alter the 
 advertisements your application sees and reduce the revenue your application earns through Snakk.
 
 If the willLeave parameter is YES, then your application is moved to the background shortly after this method returns. In this situation, your method 
 implementation does not need to perform additional work. If willLeave is set to NO, then the triggered action will cover your application’s user 
 interface to show the advertising action. Although your application continues to run normally, your implementation of this method should disable 
 activities that require user interaction while the action is executing. For example, a game might pause its game play until the user finishes 
 watching the advertisement.
 */
- (BOOL)snakkBannerAdViewActionShouldBegin:(SnakkBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave;

/**
 Called before a banner view finishes executing an action that covered your application's user interface.
 
 @param bannerView The banner view that will finish executing an action.
 */
- (void)snakkBannerAdViewActionWillFinish:(SnakkBannerAdView *)bannerView;

/**
 Called after a banner view finishes executing an action that covered your application's user interface.

 @param bannerView The banner view that finished executing an action.
 */
- (void)snakkBannerAdViewActionDidFinish:(SnakkBannerAdView *)bannerView;

@end




@class SnakkInterstitialAd;

@protocol SnakkInterstitialAdDelegate <NSObject>
@required

/**
 Called when an full-screen ad fails to load a new advertisement. (required)
 
 @param interstitialAd The full-screen ad that received the error.
 @param error The error object that describes the problem.
 
 Although the error message informs your application about why the error occurred, normally your application does not need to display the error to the user.
 
 When an error occurs, your delegate should release the ad object.
 */
- (void)snakkInterstitialAd:(SnakkInterstitialAd *)interstitialAd didFailWithError:(NSError *)error;

/**
 Called after a full-screen ad disposes of its content. (required)
 
 @param interstitialAd The interstitial ad that disposed of its content.
 
 An ad object may unload its content for a number of reasons, including such cases as when an error occurs, after a user dismisses 
 an advertisement that was presented modally, or after an advertisement’s contents have been loaded for a long period of time. 
 The ad object automatically removes its contents from the screen if it was already presented to the user. 
 Your implementation of this method should release the ad object.
 */
- (void)snakkInterstitialAdDidUnload:(SnakkInterstitialAd *)interstitialAd;


@optional

/**
 Called before the advertisement loads its content.
 
 @param interstitialAd The ad object that is about to load a new advertisement.
 */
- (void)snakkInterstitialAdWillLoad:(SnakkInterstitialAd *)interstitialAd;

/**
 Called after the advertisement loads its content.
 
 @param interstitialAd The ad object that loaded a new advertisement.
 */
- (void)snakkInterstitialAdDidLoad:(SnakkInterstitialAd *)interstitialAd;

/**
 Called before a banner view executes an action.
 
 @param interstitialAd The full-screen ad that the user tapped.
 @param willLeave YES if another application will be launched to execute the action; NO if the action is going to be executed inside your appliaction.
 
 @return Your delegate returns YES if the banner action should execute; NO to prevent the banner action from executing.
 
 When the user taps a presented advertisement, the ad’s delegate is called to inform your application that the user wants to interact with the ad. 
 To allow the action to be triggered, your method should return YES; to suppress the action, your method returns NO. Your application should almost 
 always allow actions to be triggered; preventing actions may alter the advertisements your application sees and reduce the revenue your application earns through Snakk.
 
 If the value of the willLeave parameter is YES and your delegate allows the advertisement to execute its action, then your application is moved to 
 the background shortly after the call to this method completes.
 
 If the value of the willLeave parameter is NO, the advertisement’s interactive experience will run inside your application. To accomodate the advertisement, 
 your application should disable activities that require user interaction as well as disabling any tasks or behaviors that may interfere with the advertisement. 
 For example, a game might pause its game play and turn off sound effects until the user finishes interacting with the advertisement. Further, while the 
 action is running, your application should also be prepared to respond to low-memory warnings by disposing of objects it can easily recreate after the 
 advertisement completes its action.
 */
- (BOOL)snakkInterstitialAdActionShouldBegin:(SnakkInterstitialAd *)interstitialAd willLeaveApplication:(BOOL)willLeave;

/**
 Called just before uncovering your app after once a cover action has occured.
 
 @param interstitialAd The full-screen ad that finished executing an action and will soon oncover your app.
 */
- (void)snakkInterstitialAdActionWillFinish:(SnakkInterstitialAd *)interstitialAd;

/**
 Called after a banner view finishes executing an action that covered your application's user interface.
 
 @param interstitialAd The full-screen ad that finished executing an action.
 */
- (void)snakkInterstitialAdActionDidFinish:(SnakkInterstitialAd *)interstitialAd;

@end


@class SnakkAdPrompt;

@protocol SnakkAdPromptDelegate <NSObject>
@optional

/**
 Called when an AdPrompt fails to load a new advertisement. (required)
 
 @param adPrompt The AdPrompt that received the error.
 @param error The error object that describes the problem.
 
 Although the error message informs your application about why the error occurred, normally your application does not need to display the error to the user.
 
 When an error occurs, your delegate should release the ad object.
 */
- (void)snakkAdPrompt:(SnakkAdPrompt *)adPrompt didFailWithError:(NSError *)error;

/**
 Called after an AdPrompt is declined
 
 @param adPrompt The AdPrompt that was declined.
 */
- (void)snakkAdPromptWasDeclined:(SnakkAdPrompt *)adPrompt;

/**
 Called after the AdPrompt is loaded
 
 @param adPrompt The AdPrompt that loaded a new advertisement.
 */
- (void)snakkAdPromptDidLoad:(SnakkAdPrompt *)adPrompt;


/**
 Called after the AdPrompt is displayed
 
 @param adPrompt The AdPrompt that was shown.
 */
- (void)snakkAdPromptWasDisplayed:(SnakkAdPrompt *)adPrompt;

/**
 Called before an AdPrompt executes an action.
 
 @param adPrompt The AdPrompt that the user tapped.
 @param willLeave YES if another application will be launched to execute the action; NO if the action is going to be executed inside your appliaction.
 
 @return Your delegate returns YES if the action should execute; NO to prevent the banner action from executing.
 
 When the user taps a presented advertisement, the ad’s delegate is called to inform your application that the user wants to interact with the ad. 
 To allow the action to be triggered, your method should return YES; to suppress the action, your method returns NO. Your application should almost 
 always allow actions to be triggered; preventing actions may alter the advertisements your application sees and reduce the revenue your application earns through Snakk.
 
 If the value of the willLeave parameter is YES and your delegate allows the advertisement to execute its action, then your application is moved to 
 the background shortly after the call to this method completes.
 
 If the value of the willLeave parameter is NO, the advertisement’s interactive experience will run inside your application. To accomodate the advertisement, 
 your application should disable activities that require user interaction as well as disabling any tasks or behaviors that may interfere with the advertisement. 
 For example, a game might pause its game play and turn off sound effects until the user finishes interacting with the advertisement. Further, while the 
 action is running, your application should also be prepared to respond to low-memory warnings by disposing of objects it can easily recreate after the 
 advertisement completes its action.
 */
- (BOOL)snakkAdPromptActionShouldBegin:(SnakkAdPrompt *)adPrompt willLeaveApplication:(BOOL)willLeave;

/**
 Called after a AdPrompt finishes executing an action that covered your application's user interface.
 
 @param adPrompt The AdPrompt that finished executing an action.
 */
- (void)snakkAdPromptActionDidFinish:(SnakkAdPrompt *)adPrompt;

@end




@class SnakkBrowserController;

@protocol SnakkBrowserControllerDelegate <NSObject>
@required
- (void)browserControllerFailedToLoad:(SnakkBrowserController *)browserController withError:(NSError *)error;
- (BOOL)browserControllerShouldLoad:(SnakkBrowserController *)browserController willLeaveApp:(BOOL)willLeaveApp;
- (void)browserControllerLoaded:(SnakkBrowserController *)browserController willLeaveApp:(BOOL)willLeaveApp;
- (void)browserControllerWillDismiss:(SnakkBrowserController *)browserController;
- (void)browserControllerDismissed:(SnakkBrowserController *)browserController;
@end