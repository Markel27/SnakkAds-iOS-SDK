//
//  SnakkPopupAd.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SnakkAdDelegates.h"

@class SnakkRequest;

@interface SnakkAdPrompt : NSObject <UIActionSheetDelegate>

@property (assign, nonatomic) id<SnakkAdPromptDelegate> delegate;
@property (readonly) BOOL loaded;
@property (assign) BOOL showLoadingOverlay;

- (id)initWithRequest:(SnakkRequest *)request;

/**
 * preload the AdPrompt, to be shown later...
 */
- (void)load;

- (void)showAsAlert;
- (void)showAsActionSheet;

@end
