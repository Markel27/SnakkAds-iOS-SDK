#import <Foundation/Foundation.h>

@interface QueryStringBuilder : NSObject
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict withAllowedKeys:(NSArray *)allowedKeys;
@end

@interface NSDictionary (QueryStringBuilder)

- (NSString *)queryString;
- (NSString *)queryStringWithAllowedKeys:(NSArray *)allowedKeys;

@end