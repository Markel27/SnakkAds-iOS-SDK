//
//  BackgroundHelper.m
//  Snakk-iOS-Sample
//
//  Created by Geoff Speirs on 22/08/13.
//
//

#import "BackgroundHelper.h"

@implementation BackgroundHelper

+(void)updateBackgroundToOrientation:(UIImageView *)backgroundImageView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation))
    {
        if (screenRect.size.height == 480)
        {
            backgroundImageView.image = [UIImage imageNamed:@"iPhone_4_Background"];
            backgroundImageView.frame = CGRectMake(0, 0, 320, 480);
        }
        else if (screenRect.size.height == 568.0f)
        {
            backgroundImageView.image = [UIImage imageNamed:@"iPhone_5_Background"];
            backgroundImageView.frame = CGRectMake(0, -44, 320.0, 568.0f);
        }
        else if (screenRect.size.height == 1024.0f)
        {
            backgroundImageView.image = [UIImage imageNamed:@"portrait_background"];
            backgroundImageView.frame = CGRectMake(0, -44, 768, 1024);
        }
    }
    else
    {
        if (screenRect.size.height == 568.0f)
        {
            backgroundImageView.image = [UIImage imageNamed:@"landscape_iPhone5"];
            backgroundImageView.frame = CGRectMake(0, 0, 568, 320);
        }
        if (screenRect.size.height == 480)
        {
            backgroundImageView.image = [UIImage imageNamed:@"landscape_iPhone"];
            backgroundImageView.frame = CGRectMake(0, 0, 480, 320);
        }
        else if (screenRect.size.height == 1024.0f)
        {
            backgroundImageView.image = [UIImage imageNamed:@"landscape_iPad_background"];
            backgroundImageView.frame = CGRectMake(0, 0, 1024, 768);
        }
    }
}
@end
