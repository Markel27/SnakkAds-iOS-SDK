//
//  TapItMediationAdMob.h
//  NickTest
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Nick Penteado. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADMAdNetworkAdapterProtocol.h"
#import "GADMAdNetworkConnectorProtocol.h"
#import "Snakk.h"

@interface TapItMediationAdMob : NSObject <SnakkBannerAdViewDelegate, SnakkInterstitialAdDelegate, GADMAdNetworkAdapter> {
    id<GADMAdNetworkConnector> connector;
    SnakkBannerAdView *snakkAd;
    SnakkInterstitialAd *snakkInterstitial;
    // used to suppress duplicate calls to adapterWillPresentInterstitial:, adapter:clickDidOccurInBanner, and adapterWillPresentFullScreenModal:
    // (snakk sdk calls snakk[Interstitial|Banner]AdActionShouldBegin:willLeaveApplication: each time a http redirect occurs...)
    int redirectCount;
}

@property (nonatomic, retain) UIView *snakkAd;
@property (nonatomic, retain) NSObject *snakkInterstitial;

@end
