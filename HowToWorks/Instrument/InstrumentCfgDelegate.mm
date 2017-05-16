//
//  InstrumentCfgDelegate.cpp
//  Instrument
//
//  Created by Liu Liang on 13-12-23.
//  Copyright (c) 2013年 Liu Liang. All rights reserved.
//

//
//  InstrumentCfgDelegate.cpp
//  Instrument
//
//  Created by Liu Liang on 13-12-20.
//  Copyright (c) 2013年 Liu Liang. All rights reserved.
//

#import "InstrumentCfgDelegate.h"
#include "InstrumentWinDelegate.h"


@implementation InstrumentCfgWinDelegate

- (id)init
{
    self = [super initWithWindowNibName:@"InstrumentCfgPanel"];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

-(void)awakeFromNib
{
    
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    InstrumentWinDelegate * main = (InstrumentWinDelegate *)[winInstrument delegate];
    
    [self InitialCtls:[main dicConfiguration]];
    
}


-(int)InitialCtls:(NSMutableDictionary *)dicConfiguration
{
    return 0;
}

-(int)SaveConfig
{
    InstrumentWinDelegate * main = (InstrumentWinDelegate *)[winInstrument delegate];
    [[main dicConfiguration] writeToFile:[main strCfgFile] atomically:YES];
    return 0;
}


-(IBAction)btOK:(id)sender
{
    [NSApp stopModalWithCode:1];        //OK
    [winConfig orderOut:nil];//隐藏登录窗口
    [winInstrument makeKeyAndOrderFront:nil];
    [self SaveConfig];
}
-(IBAction)btCancel:(id)sender
{
    [NSApp stopModalWithCode:0];        //Cancel
    [winConfig orderOut:nil];//隐藏登录窗口
    [winInstrument makeKeyAndOrderFront:nil];
}

-(BOOL) windowShouldClose:(NSWindow *)sender
{
    /*
    [winConfig orderOut:nil];
    [NSApp endSheet:winConfig returnCode:1];
    return NO;*/
    
    [NSApp stopModalWithCode:0];        //Cancel
    [winConfig orderOut:nil];//隐藏登录窗口
    [winInstrument makeKeyAndOrderFront:nil];
    return NO;
}

-(IBAction)btRescan:(id)sender
{
}
@end
