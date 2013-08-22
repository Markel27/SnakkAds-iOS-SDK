//
//  SnakkRequest.h
//  Snakk iOS SDK
//
//  Copyright (c) 2013 Snakk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SnakkRequest : NSObject

@property (nonatomic, assign) NSUInteger locationPrecision;

+ (SnakkRequest *)requestWithAdZone:(NSString *)zone;
+ (SnakkRequest *)requestWithAdZone:(NSString *)zone andCustomParameters:(NSDictionary *)theParams;

- (void)updateLocation:(CLLocation *)location;

- (id)customParameterForKey:(NSString *)key;
- (id)setCustomParameter:(id)value forKey:(NSString *)key;
- (id)removeCustomParameterForKey:(NSString *)key;

@end
