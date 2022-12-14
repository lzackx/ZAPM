//
//  ZAPM.h
//  ZAPM
//
//  Created by lZackx on 2022/8/1.
//

#ifndef ZAPM_h
#define ZAPM_h

//#define ZAPM_DEBUG 1

#if ZAPM_DEBUG
#define ZAPMLog(s, ...) NSLog(@"[ZAPM]: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])
#else
#define ZAPMLog(...)
#endif


#import "ZAPMManager.h"


#endif /* ZAPM_h */
