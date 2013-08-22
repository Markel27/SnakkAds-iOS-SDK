//
//  SnakkHelpers.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//
//

#import "SnakkHelpers.h"

#define DegreesToRadians(degrees) (degrees * M_PI / 180)

UIInterfaceOrientation SnakkInterfaceOrientation()
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

UIWindow *SnakkKeyWindow()
{
    return [UIApplication sharedApplication].keyWindow;
}

UIViewController *SnakkTopViewController()
{
    UIWindow* window = SnakkKeyWindow();
    UIViewController *top = window.rootViewController;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000 // iOS 5.0+
    if ([top respondsToSelector:@selector(presentedViewController)]) {
        while (top.presentedViewController) {
            top = top.presentedViewController;
            
            if ([top isKindOfClass:[UINavigationController class]]) {
                if (((UINavigationController *)top).visibleViewController) {
                    top = ((UINavigationController *)top).visibleViewController;
                }
            }
            else if ([top isKindOfClass:[UITabBarController class]]) {
                if (((UITabBarController *)top).selectedViewController) {
                    top = ((UITabBarController *)top).selectedViewController;
                }
            }
        }
    }
#endif

    return top;
}


CGFloat SnakkStatusBarHeight() {
    if ([UIApplication sharedApplication].statusBarHidden) {
        return 0.0;
    }
    
    CGSize size = [UIApplication sharedApplication].statusBarFrame.size;
    return MIN(size.width, size.height);
}

CGRect SnakkApplicationFrame(UIInterfaceOrientation orientation)
{
    CGRect frame = SnakkScreenBounds(orientation);
    CGFloat barHeight = SnakkStatusBarHeight();
    frame.origin.y += barHeight;
    frame.size.height -= barHeight;
    
    return frame;
}

CGRect SnakkScreenBounds(UIInterfaceOrientation orientation)
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        CGFloat width = bounds.size.width;
        bounds.size.width = bounds.size.height;
        bounds.size.height = width;
    }
    
    return bounds;
}


CGAffineTransform SnakkRotationTransformForOrientation(UIInterfaceOrientation orientation) {
    CGFloat angle = 0.0;
    
    
//    switch (orientation) {
//            
//        case UIInterfaceOrientationLandscapeLeft:
//            angle = -DegreesToRadians(90);
//        case UIInterfaceOrientationLandscapeRight:
//            angle = DegreesToRadians(90);
//        case UIInterfaceOrientationPortraitUpsideDown:
//            angle = DegreesToRadians(180);
//        case UIInterfaceOrientationPortrait:
//        default:
//            angle = DegreesToRadians(0);
//    }
    switch (orientation) {
        case UIInterfaceOrientationPortraitUpsideDown: angle = M_PI; break;
        case UIInterfaceOrientationLandscapeLeft: angle = -M_PI_2; break;
        case UIInterfaceOrientationLandscapeRight: angle = M_PI_2; break;
        default: break;
    }
    
    return CGAffineTransformMakeRotation(angle);
}