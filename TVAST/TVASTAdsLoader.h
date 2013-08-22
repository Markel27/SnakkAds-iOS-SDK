//
//  TVASTAdsLoader.h
//  Snakk Rich Meda Ads SDK
//
//  Created by Snakk Media on 8/22/2013.
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVASTVideoAdsManager.h"
#import "TVASTAdsRequest.h"
#import "TVASTAdError.h"

/// Ad loaded data that is returned when the adsLoader loads the ad.
@interface TVASTAdsLoadedData : NSObject

/// The ads manager returned by the adsLoader.
@property(nonatomic, retain) TVASTVideoAdsManager *adsManager;
/// Other user context object returned by the adsLoader.
@property(nonatomic, retain) id userContext;

@end

/// Ad error data that is returned when the adsLoader failed to load the ad.
@interface TVASTAdLoadingErrorData : NSObject

/// The ad error that occured while loading the ad.
@property(nonatomic, retain) TVASTAdError *adError;
/// Other user context object returned by the adsLoader.
@property(nonatomic, retain) id userContext;

@end

@class TVASTAdsLoader;

/// Delegate object that receives state change callbacks from IMAAdsLoader.
@protocol TVASTAdsLoaderDelegate<NSObject>

/// Called when ads are successfully loaded from the ad servers by the loader.
- (void)adsLoader:(TVASTAdsLoader *)loader
    adsLoadedWithData:(TVASTAdsLoadedData *)adsLoadedData;

/// Error reported by the ads loader when ads loading failed.
- (void)adsLoader:(TVASTAdsLoader *)loader
    failedWithErrorData:(TVASTAdLoadingErrorData *)adErrorData;

@end

/// The TVASTAdsLoader class allows requesting ads from various ad servers.
//
/// To do so, IMAAdsLoaderDelegate must be implemented and then ads should
/// be requested.
@interface TVASTAdsLoader : NSObject

/// Request ads by providing the ads |request| object with properties populated
/// with parameters to make an ad request to Google or DoubleClick ad server.
/// Optionally, |userContext| object that is associated with the ads request can
/// be provided. This can be retrieved when the ads are loaded.
- (void)requestAdsWithRequestObject:(TVASTAdsRequest *)request
                        userContext:(id)context;

/// Request ads from a adsserver by providing the ads request object.
- (void)requestAdsWithRequestObject:(TVASTAdsRequest *)request;

/// Delegate object that receives state change notifications from this
/// IMAAdsLoader. Remember to nil the delegate before releasing this
/// object.
@property(nonatomic, assign) NSObject<TVASTAdsLoaderDelegate> *delegate;

@end
