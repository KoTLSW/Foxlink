//
//  InstrumentCfgDelegate.h
//  Instrument
//
//  Created by Liu Liang on 13-12-23.
//  Copyright (c) 2013年 Liu Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface InstrumentCfgWinDelegate : NSWindowController{
    
@private
    IBOutlet NSWindow * winConfig;
    IBOutlet NSWindow * winInstrument;
}

-(IBAction)btOK:(id)sender;
-(IBAction)btCancel:(id)sender;

-(int)InitialCtls:(NSMutableDictionary *)dicConfiguration;
-(int)SaveConfig;

@end

