//
//  Item.m
//  B312_BT_MIC_SPK
//
//  Created by h on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Item.h"
//=============================================
@interface Item()
{
    NSString*   _testName;
    NSString*   _testLowerLimit;
    NSString*   _testUpperLimit;
    NSString*   _testValueUnit;
    NSString*   _testValue;
    NSString*   _testResult;
    NSString*   _testMessage;
    NSString*   _testDevice;
    NSString*   _testCommand;
    NSInteger   _testRetryTimes;
    NSArray*    _testAllCommand;
    BOOL      _isNeedShow;
    BOOL      _isNeedTest;
    BOOL      _isPdcaValue;
}
//=============================================
@end
//=============================================
@implementation Item
//=============================================
@synthesize testName        = _testName;
@synthesize testLowerLimit  = _testLowerLimit;
@synthesize testUpperLimit  = _testUpperLimit;
@synthesize testValueUnit   = _testValueUnit;
@synthesize testValue       = _testValue;
@synthesize testResult      = _testResult;
@synthesize testMessage     = _testMessage;
@synthesize testDevice      = _testDevice;
@synthesize testCommand     = _testCommand;
@synthesize testRetryTimes  = _testRetryTimes;
@synthesize isNeedShow      = _isNeedShow;
@synthesize isNeedTest      = _isNeedTest;
@synthesize isPdcaValue     = _isPdcaValue;
@synthesize testAllCommand  = _testAllCommand;
//=============================================
@end
//=============================================
