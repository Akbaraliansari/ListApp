//
//  NSDictionary+safety.m
//  
//
//  Created by Ansari on 13/11/15.
//
//

#import "NSDictionary+safety.h"

@implementation NSDictionary (safety)
- (id)safeObjectForKey:(id)aKey {
    NSObject *object = self[aKey];
    
    if (object == [NSNull null]) {
        return @"";
    }
    
    return object;
}
@end
