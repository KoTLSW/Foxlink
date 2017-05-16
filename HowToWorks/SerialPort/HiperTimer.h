//
//  HiperTimer.h
//  SerialPortDemo
//
//  Created by TOD on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>

@interface HiperTimer : NSObject 
{
@private

	struct timeval tv;
	uint64_t mStart;
	uint64_t mEnd;
	
}

-(int) durationMillisecond; //get the millisencond from timer start

+(void) DelaySecond:(double) delaytime;
+(void) DelayMillsecond:(int) delaytime;

-(void) Start;
-(void) Stop;

@end
