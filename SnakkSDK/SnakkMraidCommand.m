//
//  SnakkMraidCommand.m
//  Snakk-iOS-Sample
//
//  Created by Snakk Media on 8/22/2013.
//
//

#import "SnakkMraidCommand.h"
#import "SnakkHelpers.h"
#import "SnakkAdManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@implementation SnakkMraidCommand
@synthesize adView;

+ (NSMutableDictionary *)sharedCommandClassMap {
    static NSMutableDictionary *sharedMap = nil;
    @synchronized(self) {
        if (!sharedMap) {
            sharedMap = [[NSMutableDictionary alloc] init];
            [sharedMap setObject:[SnakkMraidExpandCommand class] forKey:[SnakkMraidExpandCommand commandName]];
            [sharedMap setObject:[SnakkMraidOpenCommand class] forKey:[SnakkMraidOpenCommand commandName]];
            [sharedMap setObject:[SnakkMraidCloseCommand class] forKey:[SnakkMraidCloseCommand commandName]];
            [sharedMap setObject:[SnakkMraidCustomCloseButtonCommand class] forKey:[SnakkMraidCustomCloseButtonCommand commandName]];
            [sharedMap setObject:[SnakkMraidSetOrientationPropertiesCommand class] forKey:[SnakkMraidSetOrientationPropertiesCommand commandName]];
            [sharedMap setObject:[SnakkMraidLogCommand class] forKey:[SnakkMraidLogCommand commandName]];
        }
    }
    return sharedMap;
}

+ (void)registerCommand:(Class)command {
    NSMutableDictionary *map = [self sharedCommandClassMap];
    @synchronized(self) {
        [map setValue:command forKey:[command commandName]];
    }
}

+ (id)command:(NSString *)command {
    NSMutableDictionary *map = [self sharedCommandClassMap];
    @synchronized(self) {
        Class klass = [map objectForKey:command];
        return [[[klass alloc] init] autorelease];
    }
}

+ (NSString *)commandName {
    return @"";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidCloseCommand

+ (NSString *)commandName {
    return @"close";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    TILog(@"MRAID CLOSE");
    
    [delegate mraidClose];
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidExpandCommand

+ (NSString *)commandName {
    return @"expand";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    TILog(@"expanding! %@", params);
    NSString *urlStr = [params objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    CGRect applicationFrame = SnakkApplicationFrame(SnakkInterfaceOrientation());
    CGFloat appWidth = CGRectGetWidth(applicationFrame);
    CGFloat appHeight = CGRectGetHeight(applicationFrame);
    
    CGFloat w = CGFLOAT_MAX;
    NSNumber *tmp = [params objectForKey:@"w"];
    if (tmp) {
        w = [tmp floatValue];
    }
    w = MIN(w, appWidth);
    
    CGFloat h = CGFLOAT_MAX;
    tmp = [params objectForKey:@"h"];
    if (tmp) {
        h = [tmp floatValue];
    }
    h = MIN(h, appHeight);
    
    // Center the ad within the application frame.
    CGFloat x = applicationFrame.origin.x + floor((appWidth - w) / 2);
    CGFloat y = applicationFrame.origin.y + floor((appHeight - h) / 2);

    CGRect frame = CGRectMake(x, y, w, h);

    tmp = [params objectForKey:@"isModal"];
    BOOL isModal = tmp ? [tmp boolValue] : YES;
    tmp = [params objectForKey:@"useCustomClose"];
    BOOL useCustomClose = tmp ? [tmp boolValue] : NO;
    [delegate mraidResize:frame withUrl:url isModal:isModal useCustomClose:useCustomClose];
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidOpenCommand

+ (NSString *)commandName {
    return @"open";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    NSString *url = [params objectForKey:@"url"];
    TILog(@"MRAID open: %@", url);
    [delegate mraidOpen:url];
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidCustomCloseButtonCommand

+ (NSString *)commandName {
    return @"useCustomClose";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    BOOL useCustomClose = [(NSNumber *)[params objectForKey:@"useCustomClose"] boolValue];
    [delegate mraidUseCustomCloseButton:useCustomClose];
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidSetOrientationPropertiesCommand

+ (NSString *)commandName {
    return @"setOrientationProperties";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    BOOL allowOrientationChange = YES;
    SnakkMraidForcedOrientation forcedOrientation = MRAID_FORCED_ORIENTATION_NONE;
    [delegate mraidAllowOrientationChange:allowOrientationChange andForceOrientation:forcedOrientation];
}

@end


/**********************************************************************
 **********************************************************************/
@implementation SnakkMraidLogCommand

+ (NSString *)commandName {
    return @"log";
}

- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
    NSString *msg = [params objectForKey:@"message"];
    TILog(@"MRAID LOG: %@", msg);
}

@end


/**********************************************************************
*/

//@implementation SnakkMraidAdCalendarEvent
//
//+ (NSString *)commandName {
//    return @"addCalendarEvent";
//}
//
//- (void)executeWithParams:(NSDictionary *)params andDelegate:(id<SnakkMraidDelegate>)delegate {
//    // {description: "Mayan Apocalypse/End of World", location: "everywhere", start: "2012-12-21T00:00-05:00", end: "2012-12-22T00:00-05:00"}
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
//
////    // RFC3339 date formatting
////    NSString *dateString = @"2011-03-24T10:00:00-08:00";
////    
////    NSDate *date;
////    NSError *error = nil;
////    BOOL success = [formatter getObjectValue:&date forString:dateString range:nil error:&error];
////    if (!success) {
////        NSLog(@"Error occured while parsing date: %@", error);
////    }
////    TILog(@"NSDate from string: %@", date);
////    
////    
////    return;
//
//    
//    
//    EKEventStore *_eventStore = [[EKEventStore alloc] init];
//
//    void (^storeEvent)();
//    storeEvent = ^(void){
//        EKCalendar *defaultEventStore = [_eventStore defaultCalendarForNewEvents];
//        
//        TILog(@"event store details: %@", defaultEventStore.description);
//        
//        EKCalendar *defaultCalendar = [_eventStore defaultCalendarForNewEvents];
//        
//        // Create a new event... save and commit
//        NSError *error = nil;
//        EKEvent *myEvent = [EKEvent eventWithEventStore:_eventStore];
//        myEvent.allDay = NO;
//        myEvent.startDate = [NSDate date];
//        myEvent.endDate = [NSDate date];
//        myEvent.title = @"MRAID Calendar Event Test";
//        myEvent.calendar = defaultCalendar;
//        [myEvent addAlarm:[EKAlarm alarmWithRelativeOffset:5]];
//        
//        EKEventEditViewController *vc = [[EKEventEditViewController alloc] initWithNibName:nil bundle:nil];
//        vc.event = myEvent;
//        vc.eventStore = _eventStore;
////        vc.allowsEditing = NO;
//        vc.editViewDelegate = self;
//        
//        [[delegate mraidPresentingViewController] presentModalViewController:vc animated:NO];
//        [vc release];
//        
//        return;
//        [_eventStore saveEvent:myEvent span:EKSpanThisEvent commit:YES error:&error];
//        
//        if (!error) {
//            TILog(@"the event saved and committed correctly with identifier %@", myEvent.eventIdentifier);
//        } else {
//            TILog(@"there was an error saving and committing the event");
//            error = nil;
//        }
//        
//        EKEvent *savedEvent = [_eventStore eventWithIdentifier:myEvent.eventIdentifier];
//        TILog(@"saved event description: %@",savedEvent);
//    };
//    
//    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
//        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
//            if (error) {
//                //TODO fire off error event to JS
//                TILog(@"error! %@", error);
//            }
//            else if (!granted) {
//                //TODO fire off no permissions error to JS
//                TILog(@"not granted!");
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), storeEvent);
//            }
//        }];
//        
//    }
//    else {
//        TILog(@"the old way...");
//        storeEvent();
//    }
//    
//    [formatter release];
//    [_eventStore release];
//}
//
//- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action {
//    switch (action) {
//        case EKEventEditViewActionCancelled:
//            TILog(@"cancelled");
//            break;
//        case EKEventEditViewActionDeleted:
//            TILog(@"deleted");
//            break;
//        case EKEventEditViewActionSaved:
//            TILog(@"saved");
//
//            NSError *error = nil;
//            [controller.eventStore saveEvent:controller.event span:EKSpanThisEvent commit:YES error:&error];
//            
//            if (!error) {
//                TILog(@"the event saved and committed correctly with identifier %@", controller.event.eventIdentifier);
//            } else {
//                TILog(@"there was an error saving and committing the event");
//                error = nil;
//            }
//            
//            EKEvent *savedEvent = [controller.eventStore eventWithIdentifier:controller.event.eventIdentifier];
//            
//            break;
//        default:
//            break;
//    }
//    [controller dismissModalViewControllerAnimated:YES];
//    TILog(@"eventEditViewController:didCompleteWithAction:");
//}
//@end

