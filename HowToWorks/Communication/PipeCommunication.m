//
//  PipeCommunication.m
//  FCMTest
//
//  Created by MINI-007 on 30/1/15.
//  Copyright (c) 2015年 MINI-007. All rights reserved.
//

#import "PipeCommunication.h"

static PipeCommunication* pipeComm=nil;

@implementation PipeCommunication

@synthesize strOptions=_strOptions;
@synthesize strLaunchPath=_strLaunchPath;

+(PipeCommunication*)Instance
{
    if(nil==pipeComm)
    {
        pipeComm=[[PipeCommunication alloc] init];
    }
    
    return pipeComm;
}

-(id)init
{
    if(self=[super init])
    {
        //运行终端
        _strLaunchPath=[[NSString alloc] initWithString:@"/bin/sh"];
        _strOptions=[[NSString alloc] initWithString:@"-c"];
    }
    
    return self;
}

-(void)dealloc
{
    [_strOptions release];
    [_strLaunchPath release];
    [super dealloc];
}

//初始化属性，即设置启动属性为sh@"/bin/sh"命令行
-(void)InitProperty
{
    _strOptions=@"-c";
    _strLaunchPath=@"/bin/sh";
}

//设置运行路径
-(void) SetProperty:(NSString*)launchPath andOptions:(NSString*)options
{
    _strOptions=options?options:_strOptions;
    _strLaunchPath=launchPath?launchPath:_strLaunchPath;
}

//运行命令行
-(NSString*)SendCommand:(NSString*)command
{
    NSPipe *pipe= [NSPipe pipe];
    NSTask *task= [[NSTask alloc] init];
    [task setLaunchPath:_strLaunchPath];
    [task setArguments:[NSArray arrayWithObjects:_strOptions,command,nil]];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [NSThread sleepForTimeInterval:0.1];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

//运行命令行, 时间是毫秒
-(NSString*)SendCommand:(NSString*)command andDelayTime:(int)time
{
    NSPipe *pipe= [NSPipe pipe];
    NSTask *task= [[NSTask alloc] init];
    [task setLaunchPath:_strLaunchPath];
    
    [task setArguments:[NSArray arrayWithObjects:_strOptions,command,nil]];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [NSThread sleepForTimeInterval:(time/1000)];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    [task release];

    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

//
-(NSString*)RunTaskByPassArrayArgument:(NSArray *)arrayArgument andDelayTime:(int)time
{
    NSPipe *pipe= [NSPipe pipe];
    NSTask *task= [[NSTask alloc] init];
    [task setLaunchPath:_strLaunchPath];
    [task setArguments:arrayArgument];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    [task launch];
    [NSThread sleepForTimeInterval:(time/1000)];
    //    NSData *data;
    
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSString* strValue=[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    
    NSLog(@"Terminal back value:%@",strValue);
    [task waitUntilExit];
    [task release];
    
    return strValue;
}

@end
