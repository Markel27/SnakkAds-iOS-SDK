//
//  main.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        int retVal = -1;
        
        @try
        {
            retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch (NSException *exception) {
            NSLog(@"*** Terminating app due to uncaught exception: %@", [exception reason]);
            NSLog(@"Stack trace: %@", [exception callStackSymbols]);
            [exception raise];
        }
        
        return retVal;
    }
}
