//
//  SnakkHelpers.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


UIInterfaceOrientation SnakkInterfaceOrientation();
UIWindow *SnakkKeyWindow();
UIViewController *SnakkTopViewController();
CGFloat SnakkStatusBarHeight();
CGRect SnakkApplicationFrame(UIInterfaceOrientation orientation);
CGRect SnakkScreenBounds(UIInterfaceOrientation orientation);
CGAffineTransform SnakkRotationTransformForOrientation(UIInterfaceOrientation orientation);