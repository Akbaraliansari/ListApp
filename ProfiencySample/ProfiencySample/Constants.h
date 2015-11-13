//
//  Constants.h
//  ProfiencySample
//
//  Created by Balasubramaniyan M on 13/11/15.
//  Copyright (c) 2015 Ansari. All rights reserved.
//

#ifndef ProfiencySample_Constants_h
#define ProfiencySample_Constants_h

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SUBMIT_SCREEN_HEIGHT SCREEN_HEIGHT - 59

#define CALCULATED_HEIGHT(h) (float)((float)h/568)*SCREEN_HEIGHT
#define CALCULATED_WIDTH(w) (float)((float)w/320)*SCREEN_WIDTH

#define UIColorWithRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((float)a)]
#if !defined(StringOrEmpty)
#define StringOrEmpty(A)  ({ __typeof__(A) __a = (A); __a ? __a : @""; })
#endif
#endif
