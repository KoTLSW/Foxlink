//
//  Item.h
//  B312_BT_MIC_SPK
//
//  Created by h on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property(readwrite,copy)NSString* testName;
@property(readwrite,copy)NSString* testLowerLimit;
@property(readwrite,copy)NSString* testUpperLimit;
@property(readwrite,copy)NSString* testValueUnit;
@property(readwrite,copy)NSString* testValue;
@property(readwrite,copy)NSString* testResult;
@property(readwrite,copy)NSString* testMessage;
@property(readwrite,copy)NSString* testDevice;
@property(readwrite,copy)NSString* testCommand;
@property(readwrite,copy)NSArray * testAllCommand; //2017.5.4
@property(readwrite)NSInteger      testRetryTimes;
@property(readwrite)BOOL           isNeedShow;
@property(readwrite)BOOL           isNeedTest;
@property(readwrite)BOOL           isPdcaValue;

@end
