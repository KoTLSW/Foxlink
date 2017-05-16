//
//  Folder.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "Folder.h"
@interface Folder (){

}
@end

@implementation Folder

- (NSString*)Folder_GetCurrentPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [fm currentDirectoryPath];
    return path;
    
}
-(BOOL) Folder_SetCurrentPath:(NSString*)newPath
{
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm changeCurrentDirectoryPath:fm];
}
-(BOOL) Folder_Creat:(NSString*)path
{
     NSFileManager *fm = [NSFileManager defaultManager];
    return [fm createDirectoryAtPath:path attributes:nil];
}
-(BOOL) Foleer_Rename:(NSString*)oldstr new:(NSString*)newstr
{
     NSFileManager *fm = [NSFileManager defaultManager];
    return [fm movePath:oldstr toPath:newstr handler:nil];
}

@end
