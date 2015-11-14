//
//  NSDictionary+safety.h
//  
//
//  Created by Ansari on 13/11/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (safety)
- (id)safeObjectForKey:(id)aKey;
@end
