//
//  LoginWindowController.m
//  HowToWorks
//
//  Created by h on 17/3/28.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "LoginWindowController.h"
#import "AppDelegate.h"

static NSString *const kStoryboardName = @"Main";
static NSString *const kLoginWindowControllerIdentifier = @"LoginWindowController";
@implementation LoginWindowController

-(void)windowDidLoad{
    [super windowDidLoad];
    AppDelegate *appDelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
    appDelegate.mainWindowController = self;
    [self.window center];
}

+(instancetype)windowController{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    LoginWindowController *loginWC = [storyboard instantiateControllerWithIdentifier:kLoginWindowControllerIdentifier];
    //设置动画样式
    [loginWC.window setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
    return loginWC;
}

@end
