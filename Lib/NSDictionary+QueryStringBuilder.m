#import "NSDictionary+QueryStringBuilder.h"

static NSString * escapeString(NSString *unencodedString)
{
  NSString *s = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
        (CFStringRef)unencodedString,
        NULL,
        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
        kCFStringEncodingUTF8);
  return [s autorelease];

}

@implementation QueryStringBuilder
+ (NSString *)queryStringFromDictionary:(NSDictionary *)dict withAllowedKeys:(NSArray *)allowedKeys {
    NSMutableString *queryString = nil;
    if (nil == allowedKeys) {
        allowedKeys = [dict allKeys];
    }
    
    if ([allowedKeys count] > 0) {
        for (id key in allowedKeys) {
            if (nil != key) {
                id value = [dict objectForKey:key];
                if (nil != value) {
                    if (nil == queryString) {
                        queryString = [[[NSMutableString alloc] init] autorelease];
                    }
                    else {
                        [queryString appendFormat:@"&"];
                    }
                    
                    if ([value isKindOfClass:[NSString class]]) {
                        [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
                    }
                    else if ([value isKindOfClass:[NSNumber class]]) {
                        [queryString appendFormat:@"%@=%@", escapeString(key), [value stringValue]];
                    }
                    else if ([value isKindOfClass:[NSNull class]]) {
                        [queryString appendFormat:@"%@", escapeString(key)];
                    }
                }
            }
        }
    }
    
    return queryString;
}

@end

@implementation NSDictionary (QueryStringBuilder)

- (NSString *)queryString {
    return [self queryStringWithAllowedKeys:nil];    
}

- (NSString *)queryStringWithAllowedKeys:(NSArray *)allowedKeys
{
    NSMutableString *queryString = nil;
    if (nil == allowedKeys) {
        allowedKeys = [self allKeys];
    }
    
    if ([allowedKeys count] > 0) {
        for (id key in allowedKeys) {
            if (nil != key) {
                id value = [self objectForKey:key];
                if (nil != value) {
                    if (nil == queryString) {
                        queryString = [[[NSMutableString alloc] init] autorelease];
                    }
                    else {
                        [queryString appendFormat:@"&"];
                    }
                    
                    if ([value isKindOfClass:[NSString class]]) {
                        [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
                    }
                    else if ([value isKindOfClass:[NSNumber class]]) {
                        [queryString appendFormat:@"%@=%@", escapeString(key), [value stringValue]];
                    }
                    else if ([value isKindOfClass:[NSNull class]]) {
                        [queryString appendFormat:@"%@", escapeString(key)];
                    }
                }
            }
        }
    }
    
    return queryString;
}

@end
