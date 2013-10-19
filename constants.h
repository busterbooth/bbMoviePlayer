//
//  constants.h
//  AthensPublic
//
//  Created by Eddie Boswell on 9/24/13.
//  Copyright (c) 2013 Athens Public Access. All rights reserved.
//

#ifndef AthensPublic_constants_h
#define AthensPublic_constants_h

#define URL_PREFIX @"https://busterboothcom.netfirms.com/athenspublic/mobile/"
#define FEED_URL @"https://busterboothcom.netfirms.com/athenspublic/streaming/live/getfeed.php"
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
#endif
