//
//  SnakkRequest.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "SnakkRequest.h"
#import "SnakkPrivateConstants.h"
#import "NSDictionary+QueryStringBuilder.h"
#import "SnakkAppTracker.h"


@interface SnakkRequest () 

@property (retain, nonatomic) NSString *adZone;
@property (retain, nonatomic) NSMutableDictionary *parameters;
@property (retain, nonatomic) NSString *rawResults;

+(NSArray *)allowedServerVariables; //TODO probably needs to be moved to bannerview/interstitialcontroller to allow for different acceptable params for each

- (NSURLRequest *)getURLRequest;

@end

@implementation SnakkRequest

@synthesize adZone, parameters, rawResults, locationPrecision;


+ (SnakkRequest *)requestWithAdZone:(NSString *)zone {
    return [SnakkRequest requestWithAdZone:zone andCustomParameters:nil];
}

+ (SnakkRequest *)requestWithAdZone:(NSString *)zone andCustomParameters:(NSDictionary *)theParams {
    SnakkRequest *ret = [[[SnakkRequest alloc] init] autorelease];
    ret.adZone = zone;
    if (theParams) {
        [ret.parameters addEntriesFromDictionary:theParams];
    }
    return ret;
}

- (id)init {
    self = [super init];
    if (self) {
        NSMutableDictionary *parms = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.parameters = parms;
        [parms release];
    }
    return self;
}

- (NSURLRequest *)getURLRequest {
    [self setDefaultParams];
    NSString *urlStr = [NSString stringWithFormat:@"%@?%@",
                        SNAKK_AD_SERVER_URL,
                        [QueryStringBuilder queryStringFromDictionary:self.parameters withAllowedKeys:[SnakkRequest allowedServerVariables]]
//                        [self.parameters queryStringWithAllowedKeys:[SnakkRequest allowedServerVariables]]
                        ];
    NSLog(@"Snakk Request: %@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.0] autorelease];
    return req;
    
}

+(NSArray *)allowedServerVariables {
    static NSArray *allowedServerVariables;
    
    if (nil == allowedServerVariables) {
        allowedServerVariables = [[NSArray arrayWithObjects:
                                  @"zone",
                                  @"h", // height
                                  @"w", // width
                                  @"o", // orientation == @"p" (portrait), or @"l" (landscape)
                                  @"ua", // user agent
                                  @"udid",
                                  @"ifa", // id for advertising
                                  @"ate", // advertising tracking enabled == 0 (disabled), 1 (enabled)
                                  @"format",
                                  @"ip",
                                  @"mode", // == @"test" for test mode, else production
                                  @"lat", // latitude
                                  @"long", // longitude
                                  @"adtype",
                                  @"cid",
                                  @"carrier",
                                  @"carrier_id",
                                  @"client",
                                  @"mediation",
                                  @"version",
                                  @"connection_speed",
                                  nil] retain];
    }
    
    return allowedServerVariables;
}

#pragma mark -
#pragma mark geotargeting code

- (void)updateLocation:(CLLocation *)location {
    // update the request object so that the server gets the new location for the next ad request
	static NSNumberFormatter *formatter = nil;
	if (!formatter) {
        formatter = [[NSNumberFormatter alloc] init];
    }
    
    NSNumber *lat = [NSNumber numberWithFloat:location.coordinate.latitude];
	NSNumber *lon = [NSNumber numberWithFloat:location.coordinate.longitude];
    
	[formatter setMaximumFractionDigits:self.locationPrecision];
    
    [self setCustomParameter:lat forKey:@"lat"];
    [self setCustomParameter:lon forKey:@"long"];
}

#pragma mark -
#pragma mark customParams methods

- (id)customParameterForKey:(NSString *)key {
    return [parameters objectForKey:key];
}

- (id)setCustomParameter:(id)value forKey:(NSString *)key {
    NSString *oldVal = [parameters objectForKey:key];
    [parameters setObject:value forKey:key];
    return oldVal;
}

- (id)removeCustomParameterForKey:(NSString *)key {
    NSString *oldVal = [parameters objectForKey:key];
    [parameters removeObjectForKey:key];
    return oldVal;
}

- (void)setDefaultParams {
    SnakkAppTracker *tracker = [SnakkAppTracker sharedAppTracker];
    NSInteger connType = [tracker networkConnectionType];

    [self setCustomParameter:self.adZone forKey:@"zone"];
    [self setCustomParameter:@"json" forKey:@"format"];
    [self setCustomParameter:[tracker deviceUDID] forKey:@"udid"];
    NSString *ifa = [tracker deviceIFA];
    if (ifa) {
        [self setCustomParameter:ifa forKey:@"ifa"];
    }
    NSInteger advertisingTrackingEnabled = [tracker advertisingTrackingEnabled];
    if (advertisingTrackingEnabled >= 0) {
        [self setCustomParameter:[NSString stringWithFormat:@"%d", advertisingTrackingEnabled] forKey:@"ate"];
    }
    [self setCustomParameter:SNAKK_VERSION forKey:@"version"];
    [self setCustomParameter:@"iOS-SDK" forKey:@"client"];
    [self setCustomParameter:[NSString stringWithFormat:@"%d", connType] forKey:@"connection_speed"];

    NSString *carrierName = [tracker carrier];
    if (carrierName) {
        [self setCustomParameter:carrierName forKey:@"carrier"];
    }
    NSString *carrierId = [tracker carrierId];
    if (carrierId) {
        [self setCustomParameter:carrierId forKey:@"carrier_id"];
    }
    [self setCustomParameter:[tracker userAgent] forKey:@"ua"];
}

-(void)dealloc {
    self.rawResults = nil;
    self.parameters = nil;
    self.adZone = nil;
    
    [super dealloc];
}
@end
