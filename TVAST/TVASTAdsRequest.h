//
//  TVASTAdsRequest.h
//  Snakk Rich Meda Ads SDK
//
//  Created by Snakk Media on 8/22/2013.
//
//  Copyright 2013 Snakk by Phunware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/// AdsRequest for loading ads from Snakk ad server.
//
/// Caller can provide ads request key and values that needs to be passed to
/// TVASTAdsLoader to request ads.
@interface TVASTAdsRequest : NSObject

@property (nonatomic, assign) NSUInteger locationPrecision;

+ (TVASTAdsRequest *)requestWithAdZone:(NSString *)zone;

+ (TVASTAdsRequest *)requestWithAdZone:(NSString *)zone andCustomParameters:(NSDictionary *)params;

/// Set a string request parameter value for a key.
- (id)setCustomParameter:(id)value forKey:(NSString *)key;

/// Get a string request parameter given a key.
- (id)customParameterForKey:(NSString *)key;

- (id)removeCustomParameterForKey:(NSString *)key;

- (void)updateLocation:(CLLocation *)location;

@end
