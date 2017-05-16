//
//  PipeCommunication.h
//  FCMTest
//
//  Created by MINI-007 on 30/1/15.
//  Copyright (c) 2015年 MINI-007. All rights reserved.
//

#ifndef PIPE_COMMUNICATION_H_H
#define PIPE_COMMUNICATION_H_H

#import <Foundation/Foundation.h>


@interface PipeCommunication : NSObject
{
    NSString*   _strLaunchPath;
    NSString*   _strOptions;
}

//要运行的程序路径
@property(readwrite,copy) NSString* strLaunchPath;

//options
@property(readwrite,copy)NSString* strOptions;

//定义一个静态对象
+(PipeCommunication*)Instance;

//初始化属性，即设置启动属性为sh@"/bin/sh"命令行
-(void)InitProperty;

//设置属性
-(void) SetProperty:(NSString*)launchPath andOptions:(NSString*)options;

//发送命令
-(NSString*)SendCommand:(NSString*)command;

//运行命令行, 时间是毫秒
-(NSString*)SendCommand:(NSString*)command andDelayTime:(int)time;

//运行命令行
-(NSString*)RunTaskByPassArrayArgument:(NSArray *)arrayArgument andDelayTime:(int)time;

@end


#endif