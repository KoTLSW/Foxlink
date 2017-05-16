//
//  Plist.m
//  B312_BT_MIC_SPK
//
//  Created by h on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Plist.h"
#import "Item.h"
//=============================================
@implementation Plist
//=============================================
- (NSMutableArray*)PlistRead:(NSString*)filename Key:(NSString*)key
{
    NSMutableArray *_testItems=[[NSMutableArray alloc]init];
    
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];

    NSArray* arrayData=[dictionary objectForKey:key];  //根据传入的关键字找到对应节点
    
    if (arrayData != nil && ![arrayData isEqual:@""])
    {
        for (NSDictionary* it in arrayData)
        {
            Item* item=[[Item alloc] init];
            
            item.testName       = [it objectForKey:@"TestName"];
            item.testLowerLimit = [it objectForKey:@"LowerLimit"];
            item.testUpperLimit = [it objectForKey:@"UpperLimit"];
            item.testValueUnit  = [it objectForKey:@"Unit"];
            item.testValue      = @"";
            item.testResult     = @"";
            item.testMessage    = @"";
            item.testDevice     = [it objectForKey:@"Device"];
            item.testCommand    = [it objectForKey:@"Command"];
            item.testRetryTimes = [[it objectForKey:@"RetryTimes"]integerValue];
            item.isNeedShow     = [[it objectForKey:@"IsShow"]boolValue];
            item.isNeedTest     = [[it objectForKey:@"IsTest"]boolValue];
            item.isPdcaValue     = NO;
            item.testAllCommand    = [it objectForKey:@"AllNeedCommands"];
            
            [_testItems addObject:item];
        }
    }
    
    return _testItems;
}
//=============================================
- (void)PlistWrite:(NSString*)filename Item:(NSString*)item
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
//    //添加一项内容
//    [data setObject:@"content" forKey:item];

//    //获取应用程序沙盒的Documents目录
//    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *path = [paths objectAtIndex:0];
//    
//    //得到完整的文件名
//    NSString *filepath=[path stringByAppendingPathComponent:filename];
//    filepath=[filepath stringByAppendingString:@".plist"];

    [data writeToFile:plistPath atomically:YES];
}
//=============================================
@end
//=============================================