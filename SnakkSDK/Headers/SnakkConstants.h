//
//  SnakkConstants.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#ifndef Snakk_iOS_Sample_SnakkConstants_h
#define Snakk_iOS_Sample_SnakkConstants_h

#define SNAKK_VERSION @"3.0.2"

typedef enum {
    SnakkBannerAdType       = 0x01,
    SnakkFullscreenAdType   = 0x02,
    SnakkVideoAdType        = 0x04,
    SnakkOfferWallType      = 0x08,
} SnakkAdType;


typedef enum {
    SnakkBannerHideNone,
    SnakkBannerHideLeft,
    SnakkBannerHideRight,
    SnakkBannerHideUp,
    SnakkBannerHideDown,
} SnakkBannerHideDirection;

#define SNAKK_PARAM_KEY_BANNER_ROTATE_INTERVAL @"RotateBannerInterval"
#define SNAKK_PARAM_KEY_BANNER_ERROR_TIMEOUT_INTERVAL @"ErrorRetryInterval"

#define SnakkDefaultLocationPrecision 6

#endif
