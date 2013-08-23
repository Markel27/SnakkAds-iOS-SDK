//
//  SnakkAdView.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import "SnakkAdView.h"
#import "SnakkPrivateConstants.h"
#import "SnakkMraidCommand.h"

@implementation SnakkAdView

@synthesize snakkRequest, snakkDelegate, isLoaded, wasAdActionShouldBeginMessageFired, interceptPageLoads;
@synthesize isMRAID, mraidDelegate, mraidState;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setScrollable:NO];
        self.delegate = self; // UIWebViewDelegate
        self.isLoaded = NO;
        self.isVisible = NO;
        self.interceptPageLoads = YES;
        self.mraidState = SNAKK_MRAID_STATE_LOADING;
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        if ([self respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
            [self setAllowsInlineMediaPlayback:YES];
        }

        if ([self respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
            [self setMediaPlaybackRequiresUserAction:NO];
        }
    }
    return self;
}

- (void)setScrollable:(BOOL)scrollable {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000 // iOS 5.0+
    if ([self respondsToSelector:@selector(scrollView)])
    {
        UIScrollView *scrollView = self.scrollView;
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    } 
    else 
#endif
    {
        UIScrollView *scrollView = nil;
        for (UIView *v in self.subviews)
        {
            if ([v isKindOfClass:[UIScrollView class]])
            {
                scrollView = (UIScrollView *)v;
                break;
            }
        }
        scrollView.scrollEnabled = scrollable;
        scrollView.bounces = scrollable;
    }
}

- (void)loadData:(NSDictionary *)adData {
    NSString *adWidth = nil;
    if ([[[adData objectForKey:@"adWidth"] class] isSubclassOfClass:[NSNumber class]])
    {
        adWidth = ((NSNumber *)[adData objectForKey:@"adWidth"]).stringValue;
    }
    else
    {
        adWidth = [NSString stringWithString:[adData objectForKey:@"adWidth"]];
    }

    NSString *width = [NSString stringWithFormat:@"width:%@px; margin:0 auto; text-align:center", adWidth];
    NSMutableString *adHtml = [NSMutableString stringWithString:[adData objectForKey:@"html"]];
    NSRange range = [adHtml rangeOfString:@"\"mraid.js\"" options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound || [adData objectForKey:@"mraid"]) {
        self.isMRAID = YES;
        self.interceptPageLoads = NO;
    }
    else {
        self.isMRAID = NO;
        self.interceptPageLoads = YES;
    }
    
    if (self.isMRAID) {
        NSString *mraidUrlPath = [adData objectForKey:@"mraid_js"];
        if (!mraidUrlPath) {
            //            mraidUrlPath = [NSString stringWithFormat:@"\"%@/mraid/mraid.js\"", SNAKK_AD_SERVER_BASE_URL];
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Snakk" ofType:@"bundle"];
            NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
            NSString *mraidPath = [bundle pathForResource:@"mraid" ofType:@"js"];
            NSURL *mraidUrl = [NSURL fileURLWithPath:mraidPath];
            mraidUrlPath = [NSString stringWithFormat:@"\"%@\"", [mraidUrl absoluteString]];
        }
        
        if (range.location != NSNotFound) {
            [adHtml replaceCharactersInRange:range withString:mraidUrlPath];
        }
        else {
            adHtml = [NSString stringWithFormat:@"<script type=\"text/javascript\" src=%@></script>", mraidUrlPath];
        }
    }
    TILog(@"MRAID is %@", (self.isMRAID ? @"ON" : @"OFF"));
    NSString *htmlData = [NSString stringWithFormat:@"<html><head><style type=\"text/css\">body {margin:0; padding:0;}</style></head><body><div style=\"%@\">%@</div></body></html>", width, adHtml];
    TILog(@"MODIFIED HTML: %@", htmlData);
    NSURL *baseUrl = nil; //[NSURL URLWithString:SNAKK_AD_SERVER_BASE_URL];
    [super loadHTMLString:htmlData baseURL:baseUrl];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
//    TILog(@"webViewDidStartLoad: %@", webView);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    TILog(@"webViewDidFinishLoad: %@", webView);
    if(!self.isLoaded || self.interceptPageLoads) {
        [self.snakkDelegate didLoadAdView:self];
    }
    self.isLoaded = YES;
    if (self.isMRAID) {
        [self fireMraidEvent:SNAKK_MRAID_EVENT_READY withParams:nil];
        self.mraidState = SNAKK_MRAID_STATE_DEFAULT;
        [self syncMraidState];
        [self fireMraidEvent:SNAKK_MRAID_EVENT_STATECHANGE withParams:self.mraidState];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // Ignore NSURLErrorDomain error -999.
    if (error.code == NSURLErrorCancelled) {
        return;   
    }
    
    // Ignore "Fame Load Interrupted" errors. Seen after app store links.
    if (error.code == 102 && [error.domain isEqual:@"WebKitErrorDomain"]) {
        return; 
    }

    [self.snakkDelegate adView:self didFailToReceiveAdWithError:error];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.isMRAID && [request.URL.absoluteString hasPrefix:@"nativecall://"]) {
        [self handleNativeCall:request.URL.absoluteURL];
        return NO;
    }

    TILog(@"shouldStartLoadWithRequest: %@", request.URL);

    if ([request.URL.absoluteString hasPrefix:@"applewebdata://"]) {
        TILog(@"Allowing applewebdata: %@", request.URL);
        return YES;
    }
    else {
        if (!([request.URL.absoluteString hasPrefix:@"http://"] || [request.URL.absoluteString hasPrefix:@"https://"])) {
            if ([[UIApplication sharedApplication] canOpenURL:request.URL])
            {
                [self.snakkDelegate adActionShouldBegin:request.URL willLeaveApplication:YES];
                [[UIApplication sharedApplication] openURL:request.URL];
                return NO;
            }
            else {
                NSLog(@"OS says it can't handle request scheme: %@", request.URL);
            }
        }
        
        if (!self.interceptPageLoads || !self.isLoaded) {
            TILog(@"Not intercepting page loads... proceed");
            // first time loading, let the ad load
            return YES;
        }

        BOOL shouldLeaveApp = NO; //TODO: figure how to answer this correctly, while taking into account redirects...
        //TODO figure out how to stop this from getting fired for each redirect!!!
        BOOL shouldLoad = [self.snakkDelegate adActionShouldBegin:request.URL willLeaveApplication:shouldLeaveApp];
        if(!shouldLoad) {
//            TILog(@"Canceling");
        }
        return shouldLoad;
    }
}

#pragma mark -
#pragma mark MRAID

- (void)syncMraidState {
    // pass over isVisible, placement type, state, max size, screen size, current position
    
    NSDictionary *containerState = [self.mraidDelegate mraidQueryState];
    NSString *placementType = [containerState objectForKey:@"placementType"];
    
    NSNumber *height = [NSNumber numberWithFloat:self.frame.size.height];
    NSNumber *width = [NSNumber numberWithFloat:self.frame.size.width];
    NSNumber *x = [NSNumber numberWithFloat:self.frame.origin.x];
    NSNumber *y = [NSNumber numberWithFloat:self.frame.origin.x];
    NSDictionary *state = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:self.isVisible], @"isVisible",
                           self.mraidState, @"state",
                           height, @"height",
                           width, @"width",
                           x, @"x",
                           y, @"y",
                           placementType, @"placementType",
                           nil];
    TILog(@"Syncing this state: %@", state);
    
    // tell JS about changes...
    [self mraidResponse:state withCallbackToken:nil];
}


- (void)setIsVisible:(BOOL)visible {
    _isVisible = visible;
    
    if (self.isMRAID) {
        [self fireMraidEvent:SNAKK_MRAID_EVENT_VIEWABLECHANGE withParams:@"[true]"];
        [self syncMraidState];
    }
}

- (void)handleNativeCall:(NSURL *)url {
    NSString *commandStr = url.host;
    
    NSString * q = [url query];
    NSArray * pairs = [q componentsSeparatedByString:@"&"];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs) {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [[bits objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [[bits objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:value forKey:key];
    }

    if (![@"log" isEqualToString:commandStr]) {
        TILog(@"Native call: %@", url);
        TILog(@"%@", commandStr);
        TILog(@"%@", params);
    }
    
    SnakkMraidCommand *command = [SnakkMraidCommand command:commandStr];
    command.adView = self;
    
    [command executeWithParams:params andDelegate:self.mraidDelegate];
//    if (![@"log" isEqualToString:commandStr]) {
//        [self syncMraidState];
//    }
}

- (void)fireMraidEvent:(NSString *)eventName withParams:(NSString *)jsonString {
    NSString *eventString;
    if (jsonString && ![jsonString hasPrefix:@"["]) {
        jsonString = [NSString stringWithFormat:@"[\"%@\"]", jsonString];
    }

    if (jsonString) {
        eventString = [NSString stringWithFormat:@"{name:\"%@\", props:%@}", eventName, jsonString];
    }
    else {
        eventString = [NSString stringWithFormat:@"{name:\"%@\"}", eventName];
    }
    TILog(@"Firing MRAID Event: %@", eventString);
    [self mraidResponse:@{@"_fire_event_": eventString} withCallbackToken:nil];
}

- (void)mraidResponse:(NSDictionary *)resposeData withCallbackToken:(NSString *)callbackToken {
    NSMutableString *dataJson = [NSMutableString stringWithString:@"{"];
    BOOL __block first = YES;
    [resposeData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(!first) {
            [dataJson appendString:@","];
        }
        else {
            first = NO;
        }
        if([obj isKindOfClass:[NSString class]] && ![obj hasPrefix:@"{"] && ![obj hasPrefix:@"["]) {
            [dataJson appendFormat:@"%@:\"%@\"", key, obj];
        }
        else {
            [dataJson appendFormat:@"%@:%@", key, obj];
        }
    }];
    
    [dataJson appendString:@"}"];
    
    NSString *js;
    if(callbackToken) {
        // responding to a live request
        js = [NSString stringWithFormat:@"mraid._nativeResponse(%@,\"%@\");", dataJson, callbackToken];
    }
    else {
        // syncing data down to js
        js = [NSString stringWithFormat:@"mraid._nativeResponse(%@);", dataJson];
    }
    TILog(@"nativeResponse: %@", js);
    [self stringByEvaluatingJavaScriptFromString:js];
}

- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (self.isMRAID) {
        CGFloat angle = 0.0;
        NSInteger deg = 0;
        if (UIInterfaceOrientationIsPortrait(orientation) ||
            UIInterfaceOrientationIsLandscape(orientation)) {
            switch (orientation) {
                case UIInterfaceOrientationPortrait:
                    // 0.0
                    break;
                case UIInterfaceOrientationLandscapeLeft:
                    angle = -M_PI_2;
                    deg = 90;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    angle = M_PI_2;
                    deg = -90;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    angle = M_PI;
                    deg = 180;
                    break;
                default:
                    // 0.0
                    break;
            }
        
            self.transform = CGAffineTransformMakeRotation(angle);

            if([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending) {
                // device is < v5.0, manually fire JS orientation updates
                NSString *javascript = [NSString stringWithFormat:
                                        @"window.__defineGetter__('orientation',function(){return %i;});"
                                        @"function(){var event = document.createEvent('Events');"
                                        @"event.initEvent('orientationchange', true, false);"
                                        @"window.dispatchEvent(event);"
                                        @"})();",
                                        deg];
                [self stringByEvaluatingJavaScriptFromString:javascript];
            }
        }
        
        
        // fire size change
        CGRect frame = SnakkApplicationFrame(orientation);
        NSString *params = [NSString stringWithFormat:@"[%i, %i]", (int)frame.size.width, (int)frame.size.height];
        [self fireMraidEvent:SNAKK_MRAID_EVENT_SIZECHANGE withParams:params];
    }
}


#pragma mark -

- (void)dealloc {
    [snakkRequest release], snakkRequest = nil;
    self.mraidDelegate = nil;
    [super dealloc];
}

@end
