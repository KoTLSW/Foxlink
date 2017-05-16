//
//  SocketDelegate.h
//  IANetFixture
//
//  Created by Yuekie on 7/5/16.
//  Copyright (c) 2016 Louis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASocket.h"
#import "ColorButtonView.h"
//#include <iostream>
#define CONNECTED_STATUS            "Connected"
#define DISCONNECTED_STATUS         "Disconnected"
#define KEY_SPArmSocketBoard        @"spArmSocketBoard"
#define KEY_SETTING_ArmSocketIp     @"settingArmSocketIp"
#define KEY_SETTING_ArmSocketPort   @"settingArmSocketPort"     //串口参数配置
#define DEFAULT_DELAY_MS            10000

@interface SocketDelegate : NSWindowController<IASocket>
{
@private
    IBOutlet NSWindow * winArmSocketBoard;
    IBOutlet NSTextView *socketLog;
    IBOutlet NSTextField *socketServerIP;
    IBOutlet NSTextField *socketServerPort;
    IBOutlet NSTextField *socketConnectionName;
    IBOutlet NSTextField * txtCmd;
    IBOutlet NSButton *ConnectToPresentServer;
    IBOutlet ColorButtonView *statusPic;
    IBOutlet NSMenuItem* MenuItem;
    //IBOutlet NSButton* FixtureState;
@private
    IBOutlet IASocket * socketClient;
    
    NSString * strCfgFile;
    
    NSTimer *emptyViewTimer;
    
    NSMutableArray * m_arrCmdHistory;
//    CIANetFixture * ArmSocketBoard;
    
    NSMutableData* m_recive_dataInput;
    
@private
    //std::mutex g_CallbackLua_mutex;
//    std::mutex g_manualLua_mutex;
    //lua_State* m_manualLua;
    //lua_State* m_CallbackLua;

}
-(int)SaveConfig:(NSString *)strfile;
-(int)TcpIpPortInitial;
-(int)LoadConfig:(NSString *)strfile;

-(IBAction)menuDebugPanel:(id)sender;
-(IBAction)btSend:(id)sender;
-(IBAction)CommandAction:(id)sender;
-(IBAction)btConnectToPresentServer:(id)sender;

- (void)SocketControlUpdate:(BOOL)State;
- (void)SendData:(NSString *)SendData;
- (void)ReceiveDataCallback:(NSString *)ReceiveData;

-(void)PrintLog:(NSString*)msg TextView: (NSTextView*)view;
-(void)PrintLogFromOutSide:(NSString*)msg ClientName: (NSString*)name;
-(int)SaveLog:(NSString *)filepath index:(int)uID;
-(char *)getLog:(int)uID ;

//FA Log
-(int)setFALog:(int)uID LogInfo:(char*)log ;
-(int)setFALogPath:(int)uID FilePath:(char*)filepath;

@property (assign) NSMutableDictionary * dicConfiguration;
@property (copy)   NSString * strCfgFile;

@end
