//
//  InstrumentWinDelegate.h
//  Instrument
//
//  Created by Liu Liang on 13-12-23.
//  Copyright (c) 2013年 Liu Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface InstrumentWinDelegate: NSWindowController
{
@private
    IBOutlet NSMenuItem* menuItem ;
    IBOutlet NSWindow* mWinDebugPanel ;
    IBOutlet NSWindow* mWinConfigPanel ;
    IBOutlet NSTextView* mLog;
    IBOutlet NSComboBox* combVisaDevice;
    IBOutlet NSComboBox* combInstrument;
    IBOutlet NSComboBox* combInstrumentType;
    IBOutlet NSComboBox* combCmd;
    IBOutlet NSTextField* txtInstrumentName;
    IBOutlet NSTextField* txtSetting;
    IBOutlet NSTextField* txtCharToDetect;
    IBOutlet NSTextField* txtTimeout;
    
    //here is config view outlet
    NSMutableDictionary *dicConfiguration ;
    NSString * strCfgFile;
    
    int DebugMsgCounter;
    NSMutableArray* arrCommands;

}

@property (assign) NSMutableDictionary * dicConfiguration;
@property (copy) NSString * strCfgFile;

-(void)PrintLog:(NSString*)strMsg;

@end

