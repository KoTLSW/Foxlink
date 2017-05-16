//
//  AppDelegate.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "AppDelegate.h"
#import "UI/PerformConfig/PerformConfigDelegate.h"
#import "SocketDelegate.h"
#import "SerialPortDelegate.h"
#import "PACSocketDebugWinDelegate.h"
#import "InstrumentCfgDelegate.h"
#import "InstrumentWinDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}
- (IBAction)newApplication:(NSMenuItem *)sender {
    NSString *executablePath = [[NSBundle mainBundle] executablePath];
    NSTask *task    = [[NSTask alloc] init];
    task.launchPath = executablePath;
    [task launch];
}
//显示TCPIP调试工具界面
- (IBAction)OnTCPIPDebugTools:(id)sender {
    if(!socketdelegate)
    {
        socketdelegate = [[SocketDelegate alloc]init];
    }
    NSLog(@"showing %@",socketdelegate);
    [socketdelegate showWindow:self];
    [socketdelegate.window center];
}
- (IBAction)OnSerialPortDebugTools:(id)sender {
    if(!serialPortDelegate)
    {
        serialPortDelegate = [[SerialPortDelegate alloc]init];
    }
    NSLog(@"showing %@",serialPortDelegate);
    [serialPortDelegate showWindow:self];
    [serialPortDelegate.window center];
}
- (IBAction)OnPerferences:(id)sender {
    if (!performconfigdelegate) {
        performconfigdelegate = [[PerformConfigDelegate alloc]init];
    }
    NSLog(@"showing %@",performconfigdelegate);
    [performconfigdelegate showWindow:self];
    [performconfigdelegate.window center];
}
- (IBAction)OnPACSocketDebugTools:(id)sender {
    if (!pacsocketDebugWinDelegate) {
        pacsocketDebugWinDelegate = [[PACSocketDebugWinDelegate alloc]init];
    }
    NSLog(@"showing %@",pacsocketDebugWinDelegate);
    [pacsocketDebugWinDelegate showWindow:self];
    [pacsocketDebugWinDelegate.window center];
}
- (IBAction)OnInstrumentDebugPanel:(id)sender {
    if (!instrumentWinDelegate) {
        instrumentWinDelegate = [[InstrumentWinDelegate alloc]init];
    }
    NSLog(@"showing %@",instrumentWinDelegate);
    [instrumentWinDelegate showWindow:self];
    [instrumentWinDelegate.window center];
}
- (IBAction)OnInstrumentConfigPanel:(id)sender {
    if (!instrumentCfgWinDelegate) {
        instrumentCfgWinDelegate = [[InstrumentCfgWinDelegate alloc]init];
    }
    NSLog(@"showing %@",instrumentCfgWinDelegate);
    [instrumentCfgWinDelegate showWindow:self];
    [instrumentCfgWinDelegate.window center];
}
















@end

