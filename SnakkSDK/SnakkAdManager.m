//
//  SnakkAdManager.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

/**
 Responsible for passing a request on to the server, parsing the response, and deciding which type of AdView object to instantiate
 */

#import "SnakkAdManager.h"
#import "SnakkRequest.h"
#import "SnakkAppTracker.h"
#import "JSONKit.h"

@interface SnakkRequest () 
@property (retain, nonatomic) NSString *rawResults;

- (NSURLRequest *)getURLRequest;
@end

@interface SnakkAdManager () {
//    NSTimer *timer;
}

    - (void)processServerResponse;
@end


@implementation SnakkAdManager {
    NSMutableData *connectionData;
    SnakkAdView *loadingAdView;
}

/**
 * handles requesting and producing ad view blocks
 */

@synthesize delegate, params, currentConnection, currentRequest;

- (SnakkAdManager *)init {
    if (self = [super init]) {
        NSMutableDictionary *cparms = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.params = cparms;
        [cparms release];
    }
    
    return self;
}

//- (void)requestBannerAdWithParams:(NSDictionary *)theParams {
//    [self cancelAdRequests];
//    [self setParams:theParams];
//    [self fireAdRequest];
//}

- (void)fireAdRequest:(SnakkRequest *)request {
    // generate a url form params
    self.currentRequest = request;
    [delegate willLoadAdWithRequest:self.currentRequest]; 
    self.currentConnection = [NSURLConnection connectionWithRequest:[self.currentRequest getURLRequest] delegate:self];
    if (self.currentConnection) {
        connectionData = [[NSMutableData data] retain];
    }
    else {
        TILog(@"Couldn't create a request connection: %@", self.currentRequest);
    }
}

- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse {
    return inRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString* rawResults = [[NSString alloc] initWithData:connectionData encoding:NSASCIIStringEncoding];

    self.currentRequest.rawResults = rawResults;
    [rawResults release];
        
    self.currentConnection = nil;
    [connectionData release], connectionData = nil;
    
    // process connectionData as json
    [self processServerResponse];
}

- (void)processServerResponse {
    NSError *error = nil;
    NSString *jsonString = self.currentRequest.rawResults;
    NSLog(@"Snakk response: %@", jsonString);
    
    JSONDecoder *decoder = [[JSONDecoder alloc] initWithParseOptions:JKParseOptionStrict];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *deserializedData = [decoder objectWithData:jsonData error:&error];
    [decoder release];

    if (error) {
        NSString *errStr;
        if (!self.currentRequest.rawResults) {
            errStr = @"Server returned an empty response";
        }
        else {
            // assume server returned a naked response
            errStr = self.currentRequest.rawResults;
        }
        NSDictionary *details = [NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:500 userInfo:details];
        [delegate adView:nil didFailToReceiveAdWithError:error];
        return;
    }
//    TILog(@"JSON Data: %@", deserializedData);
    NSString *errorMsg = [deserializedData objectForKey:@"error"];
    if (errorMsg) {
//        TILog(@"Server Returned JSON error: %@", errorMsg);
        NSDictionary *details = [NSDictionary dictionaryWithObject:errorMsg forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:400 userInfo:details];
        [delegate adView:nil didFailToReceiveAdWithError:error];
        return;
    }
    
//    NSString *adType = [NSString stringWithString:[deserializedData objectForKey:@"type"]]; // html banner ormma offerwall video
    NSString *adType = [deserializedData objectForKey:@"type"]; // html banner ormma offerwall video
    NSString *adHeight = [deserializedData objectForKey:@"adHeight"];
    int height = [adHeight intValue];
    NSString *adWidth = [deserializedData objectForKey:@"adWidth"];
    int width = [adWidth intValue];

    // generate an adView based on json object
    if ([adType isEqualToString:@"banner"] ||
        [adType isEqualToString:@"html"] ||
        [adType isEqualToString:@"text"]) {
        loadingAdView = [[SnakkAdView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        loadingAdView.snakkDelegate = self;
        [loadingAdView loadData:deserializedData];
    } else if ([adType isEqualToString:@"alert"]) {
        if ([self.delegate respondsToSelector:@selector(didReceiveData:)]) {
            [self.delegate didReceiveData:deserializedData];
        }
//    } else if ([adType isEqualToString:@"offerwall"]) {
//        //TODO: implement me!
//        adView = nil;
//    }
//    else if ([adType isEqualToString:@"video"]) {
//        //TODO: implement me!
//        adView = nil;
    }
    else {
        NSString *errStr = [NSString stringWithFormat:@"Unsupported ad type: %@ (%@)", adType, self.currentRequest.rawResults];
        NSDictionary *details = [NSDictionary dictionaryWithObject:errStr forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:NSPOSIXErrorDomain code:500 userInfo:details];
        [delegate adView:nil didFailToReceiveAdWithError:error];
        return;
    }
//    [deserializedData autorelease];
}

#pragma mark -
#pragma mark SnakkAdManagerDelegate methods

- (void)willLoadAdWithRequest:(SnakkRequest *)request {
    // pass the message on down the receiver chain
    [delegate willLoadAdWithRequest:request];
}

- (void)didLoadAdView:(SnakkAdView *)adView {
    // pass the message on down the receiver chain
    [delegate didLoadAdView:adView];
    if (adView == loadingAdView) {
        // control of adView was passed on to someone else
        [loadingAdView release], loadingAdView = nil;
    }
}

- (void)adView:(SnakkAdView *)adView didFailToReceiveAdWithError:(NSError*)error {
    // pass the message on down the receiver chain
    [delegate adView:adView didFailToReceiveAdWithError:error];
    if (adView == loadingAdView) {
        // adView never materialized. throwing away our reference
        [loadingAdView release], loadingAdView = nil;
    }
}

- (BOOL)adActionShouldBegin:(NSURL *)actionUrl willLeaveApplication:(BOOL)willLeave {
    // pass the message on down the receiver chain
//    TILog(@"AdManager->adActionShouldBegin: %@", actionUrl);
    return [delegate adActionShouldBegin:actionUrl willLeaveApplication:willLeave];
}

- (void)adViewActionDidFinish:(SnakkAdView *)adView {
    // pass the message on down the receiver chain
    [delegate adViewActionDidFinish:adView];
}

#pragma mark -

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self setCurrentConnection:nil];
    [connectionData release]; connectionData = nil;

    [delegate adView:nil didFailToReceiveAdWithError:error];
}

- (void)cancelAdRequests {
    if (loadingAdView) {
        [loadingAdView stopLoading];
        loadingAdView.snakkDelegate = nil;
        [loadingAdView release], loadingAdView = nil;
    }
    
    if (currentConnection) {
        [currentConnection cancel];
        [currentConnection release], currentConnection = nil;
    }
    
    if (connectionData) {
        [connectionData release], connectionData = nil;
    }
}

#pragma mark -

- (void)dealloc {
    [self cancelAdRequests];

    [params release], params = nil;
    [currentRequest release], currentRequest = nil;

    [super dealloc];
}

@end
