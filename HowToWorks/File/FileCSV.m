//
//  FileCSV.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "FileCSV.h"
//=======================================
@interface FileCSV (){
    NSString      *csvpath;
}
@end
//=======================================
@implementation FileCSV
//=======================================
- (id)init
{
    
    self = [super init];
    
    if (self)
    {
        csvpath = nil;
    }
    
    return self;
}
//=======================================
- (BOOL)CSV_Open:(NSString*)path
{
    
    NSFileManager *fm=[NSFileManager defaultManager];
    csvpath = path;
    
    if(![fm fileExistsAtPath:path])
    {
        [fm createFileAtPath:path contents:nil attributes:nil];
        return YES;
    }

    return NO;
    
}
//=======================================
- (void)CSV_Write:(NSString*)line
{
    if( csvpath != nil )
    {
        //创建写文件句柄
        NSFileHandle *file = [NSFileHandle fileHandleForWritingAtPath:csvpath];
        
        //找到并定位到outFile的末尾位置(在此后追加文件)
        long pos=[file seekToEndOfFile];
        
        //写入字符串
        [file writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
        
        //关闭文件
        [file closeFile];
    }
    
}
//=======================================
@end
//=======================================
