//
//  AppDelegate.h
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class SocketDelegate;
@class PerformConfigDelegate;
@class SerialPortDelegate;
@class PACSocketDebugWinDelegate;
@class InstrumentCfgWinDelegate;
@class InstrumentWinDelegate;

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    SocketDelegate *socketdelegate;
    PerformConfigDelegate *performconfigdelegate;
    SerialPortDelegate *serialPortDelegate;
    PACSocketDebugWinDelegate *pacsocketDebugWinDelegate;
    InstrumentCfgWinDelegate *instrumentCfgWinDelegate;
    InstrumentWinDelegate *instrumentWinDelegate;
}
// 强引用窗口控制器
@property (strong) NSWindowController *mainWindowController;

@end

