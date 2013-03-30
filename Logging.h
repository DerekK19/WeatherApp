//
//  Logging.h
//  FastMobile
//
//  Created by Derek Knight on 9/03/11.
//  Copyright 2011 Derek Knight. All rights reserved.
//

// How to use this
// In your .m file #define LOW_LEVEL_DEBUG as TRUE
// before you include this header file
// Use DEBUGLog instead of NSLog

// DEBUGLog will only log output if LOW_LEVEL_DEBUG is TRUE, ERRORLog will always log output

// example

//#define LOW_LEVEL_DEBUG FALSE
//
//#import "Logging.h"
//
//
// - void)myFunction
//{
//    DEBUGLog(@""); // This records the function name, which is handy
//    DEBUGLog(@"Display a message, with argument %d", 1);
//    ERRORLog(@"An error occurred: %@, [error description]);
//}

// Likewise with DETAIL_DEBUG and DETAILLog

//Note (ex http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/ ):
/*
 As for the do {} while (0) instead of nothing is because there are a few rare code situations where replacing DLog(@”"); with ; can cause issues. Replacing it with do {} while(0); is safer in those rare cases and will get optimized out by the compiler anyway.
 */

/*
 Integrates with NSLogger. If NSLogger is present then defer to it for outputting diagnostics, and always send them
 Use tags in NSLogger calls to distinguish Debug, Detail and Error, also include file and line as well a function name
 */

#if NSLOGGER_WAS_HERE == 1
#define OVERRIDE_DEBUG TRUE
#else
/*
 * Uncomment the following line to enable all debug messages
 */
#define OVERRIDE_DEBUG TRUE
#endif

#if (LOW_LEVEL_DEBUG == TRUE || OVERRIDE_DEBUG == TRUE)
#if NSLOGGER_WAS_HERE == 1
#define DEBUGLog(...) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"Debug", 1, @"%@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define DEBUGLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif
#else
#define DEBUGLog(...) do {} while(0);
#endif

#if (DETAIL_DEBUG == TRUE || OVERRIDE_DEBUG == TRUE)
#if NSLOGGER_WAS_HERE == 1
#define DETAILLog(...) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"Detail", 1, @"%@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define DETAILLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif
#else
#define DETAILLog(...) do {} while(0);
#endif

#if NSLOGGER_WAS_HERE == 1
#define ERRORLog(...) LogMessageF(__FILE__, __LINE__, __PRETTY_FUNCTION__, @"Error", 0, @"%@", [NSString stringWithFormat:__VA_ARGS__])
#else
#define ERRORLog(...) NSLog(@"%s %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif
