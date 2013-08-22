//
//  SnakkMraidCommand.h
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//
//

#import <Foundation/Foundation.h>
#import "SnakkAdView.h"
#import "SnakkMraidDelegate.h"
#import <EventKitUI/EventKitUI.h>


@interface SnakkMraidCommand : NSObject

@property(nonatomic, assign) SnakkAdView *adView;

+ (NSMutableDictionary *)sharedCommandClassMap;
+ (void)registerCommand:(Class)command;
+ (id)command:(NSString *)command;
+ (NSString *)commandName;

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate;

@end


@interface SnakkMraidCloseCommand : SnakkMraidCommand

@end


@interface SnakkMraidExpandCommand : SnakkMraidCommand

@end


@interface SnakkMraidOpenCommand : SnakkMraidCommand

@end


@interface SnakkMraidCustomCloseButtonCommand : SnakkMraidCommand

@end


@interface SnakkMraidSetOrientationPropertiesCommand : SnakkMraidCommand

@end


@interface SnakkMraidLogCommand : SnakkMraidCommand

@end

//@interface SnakkMraidAdCalendarEvent : SnakkMraidCommand <EKEventEditViewDelegate>
//@end