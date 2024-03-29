//
//  GADCustomEventExtras.h
//  Google Ads iOS SDK
//
//  Created by Lynn Nguyen on 3/15/12.
//  Copyright (c) 2013 Google Inc. All rights reserved.
//
//  Create an instance of this class to set additional parameters for each
//  custom event object. The additional parameters for a custom event are
//  keyed by the custom event label. These extras are passed to your
//  implementation of GADCustomEventBanner or GADCustomEventInterstitial.
//

#import <Foundation/Foundation.h>

#import "GADAdNetworkExtras.h"

@interface GADCustomEventExtras : NSObject <GADAdNetworkExtras>

// Set additional parameters for the custom event with label |label|. To remove
// additional parameters associated with |label|, pass in nil for |extras|.
- (void)setExtras:(NSDictionary *)extras forLabel:(NSString *)label;

// Retrieve the extras for |label|.
- (NSDictionary *)extrasForLabel:(NSString *)label;

// Removes all the extras set on this instance.
- (void)removeAllExtras;

// Returns all the extras set on this instance.
- (NSDictionary *)allExtras;

@end
