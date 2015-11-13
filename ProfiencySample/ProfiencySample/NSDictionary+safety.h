//
//  NSDictionary+safety.h
//  
//
//  Created by Balasubramaniyan M on 13/11/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (safety)
- (id)safeObjectForKey:(id)aKey;
@end
