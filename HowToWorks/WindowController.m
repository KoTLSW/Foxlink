//
//  WindowController.m
//  HowToWorks
//
//  Created by h on 17/3/29.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "WindowController.h"

static NSString *const kStoryboardName = @"Main";
static NSString *const kWindowControllerIdentifier = @"WindowController";

@implementation WindowController

+(instancetype)windowController{
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:kStoryboardName bundle:[NSBundle mainBundle]];
    WindowController *WC = [storyboard instantiateControllerWithIdentifier:kWindowControllerIdentifier];
    [WC.window setAnimationBehavior:NSWindowAnimationBehaviorDocumentWindow];
    [WC.window makeFirstResponder:nil];
    return WC;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // 居中
    [self.window center];
}

@end
