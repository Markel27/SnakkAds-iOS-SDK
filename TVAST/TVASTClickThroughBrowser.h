//
//  TVASTClickThroughBrowser.h
//  Snakk Rich Meda Ads SDK
//
//  Created by Snakk Media on 8/22/2013.
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//
//  Declares the TVASTClickThroughBrowser interface that is used to display click-
//  through links in a browser in the app. It also defines a delegate protocol
//  for notifying the app that the browser has been shown or hidden.
//

#import <UIKit/UIKit.h>

// Protocol that will be used by IMAClickThroughBrowser to signal that it has
// been opened or closed.
@protocol TVASTClickThroughBrowserDelegate

@required
- (void)browserDidOpen;
- (void)browserDidClose;

@end

// This class is used to display clickthrough links in the app.
@interface TVASTClickThroughBrowser : UIViewController<UIWebViewDelegate, UIActionSheetDelegate>

/// Enables displaying any click through in an in-app browser.
//
/// By default, clicking/tapping the ad will cause the default iOS browser to be
/// opened, switching away from the app. Call this method to enable a custom
/// in-app browser that will be created in the |viewController| provided.
/// If provided, the |delegate| can be used to track the opening and closing
/// of the in-app browser.
+ (void)enableInAppBrowserWithViewController:(UIViewController *)viewController
            delegate:(id<TVASTClickThroughBrowserDelegate>)delegate;

/// Disables displaying any click through in an in-app browser.
+ (void)disableInAppBrowser;

@end
