//
//  SnakkPrivateConstants.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#ifndef Snakk_iOS_Sample_SnakkPrivateConstants_h
#define Snakk_iOS_Sample_SnakkPrivateConstants_h

#import "SnakkConstants.h"
#import "SnakkHelpers.h"


#define SNAKK_REPORTING_SERVER_URL                          @"http://a.snakkads.com"
#define SNAKK_AD_SERVER_BASE_URL                            @"http://r.snakkads.com"
#define SNAKK_AD_SERVER_URL                                 [NSString stringWithFormat:@"%@/adrequest.php", SNAKK_AD_SERVER_BASE_URL]
#define SNAKK_CLICK_SERVER_BASE_URL                         @"http://c.snakkads.com"

#define SNAKK_PARAM_VALUE_BANNER_ROTATE_INTERVAL            120
#define SNAKK_PARAM_VALUE_BANNER_ERROR_TIMEOUT_INTERVAL     30

#define SNAKK_AD_TYPE_BANNER @"1"
#define SNAKK_AD_TYPE_INTERSTITIAL @"2"
#define SNAKK_AD_TYPE_ALERT @"10"

// MRAID CONSTS
#define SNAKK_MRAID_STATE_LOADING @"loading"
#define SNAKK_MRAID_STATE_DEFAULT @"default"
#define SNAKK_MRAID_STATE_RESIZED @"resized"
#define SNAKK_MRAID_STATE_EXPANDED @"expanded"
#define SNAKK_MRAID_STATE_HIDDEN @"hidden"

#define SNAKK_MRAID_EVENT_READY @"ready"
#define SNAKK_MRAID_EVENT_STATECHANGE @"stateChange"
#define SNAKK_MRAID_EVENT_SIZECHANGE @"sizeChange"
#define SNAKK_MRAID_EVENT_VIEWABLECHANGE @"viewableChange"
#define SNAKK_MRAID_EVENT_ERROR @"error"

#endif

#ifdef DEBUG
#define TILog(...) NSLog(__VA_ARGS__)
#else
#define TILog(...)
#endif
