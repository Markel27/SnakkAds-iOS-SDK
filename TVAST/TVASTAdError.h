//
//  TVASTAdError.h
//  Snakk Rich Meda Ads SDK
//
//  Created by Snakk Media on 8/22/2013.
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//
//  This file provides error codes that are raised internally by the SDK and
//  declares the TVASTAdError instance.

#import <Foundation/Foundation.h>

/// Possible error types while loading or playing ads.
typedef enum {
  /// An unexpected error occured while loading or playing the ads.
  //
  /// This may mean that the SDK wasn't loaded properly.
  kTVASTAdUnknownErrorType,
  /// An error occured while loading the ads.
  kTVASTAdLoadingFailed,
  /// An error occured while playing the ads.
  kTVASTAdPlayingFailed,
} TVASTErrorType;

/// Possible error codes raised while loading or playing ads.
typedef enum {
  /// Unknown error occured while loading or playing the ad.
  kTVASTUnknownErrorCode = 0,
  /// There was an error playing the video ad.
  kTVASTVideoPlayError = 1003,
  /// There was a problem requesting ads from the server.
  kTVASTFailedToRequestAds = 1004,
  /// There was an internal error while loading the ad.
  kTVASTInternalErrorWhileLoadingAds = 2001,
  /// No supported ad format was found.
  kTVASTSupportedAdsNotFound = 2002,
  /// At least one VAST wrapper ad loaded successfully and a subsequent wrapper
  /// or inline ad load has timed out.
  kTVASTVastLoadTimeout = 3001,
  /// At least one VAST wrapper loaded and a subsequent wrapper or inline ad
  /// load has resulted in a 404 response code.
  kTVASTVastInvalidUrl = 3002,
  /// The ad response was not recognized as a valid VAST ad.
  kTVASTVastMalformedResponse = 3003,
  /// A media file of a VAST ad failed to load or was interrupted mid-stream.
  kTVASTVastMediaError = 3004,
  /// The maximum number of VAST wrapper redirects has been reached.
  kTVASTVastTooManyRedirects = 3005,
  /// Assets were found in the VAST ad response, but none of them matched the
  /// video player's capabilities.
  kTVASTVastAssetMismatch = 3006,
  /// No assets were found in the VAST ad response.
  kTVASTVastAssetNotFound = 3007,
  /// Invalid arguments were provided to SDK methods.
  kTVASTInvalidArguments = 3101,
  /// A companion ad failed to load or render.
  kTVASTCompanionAdLoadingFailed = 3102,
  /// The ad response was not understood and cannot be parsed.
  kTVASTUnknownAdResponse = 3103,
  /// An unexpected error occurred while loading the ad.
  kTVASTUnexpectedLoadingError = 3104,
  /// An overlay ad failed to load.
  kTVASTOverlayAdLoadingFailed = 3105,
  /// An overlay ad failed to render.
  kTVASTOverlayAdPlayingFailed = 3106,
} TVASTErrorCode;

#pragma mark -

/// Surfaces an error that occured during ad loading or playing.
@interface TVASTAdError : NSError

/// The |errorType| accessor provides information about whether the error
/// occured during ad loading or ad playing.
@property (nonatomic, readonly) TVASTErrorType errorType;

@end
