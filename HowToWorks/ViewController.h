//
//  ViewController.h
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import "Table.h"
#import "Param.h"
#import "Plist.h"
#import "Item.h"
#import "PDCA.h"
#import "FileTXT.h"
#import "FileCSV.h"
#import "Folder.h"
#import "Alert.h"
#import "TimeDate.h"
#import "UserInformation.h"
#import "Common.h"




//=======================网口配置信息======================
#define CONNECTED_STATUS            "Connected"
#define DISCONNECTED_STATUS         "Disconnected"
#define KEY_SPArmSocketBoard        @"spArmSocketBoard"
#define KEY_SETTING_ArmSocketIp     @"settingArmSocketIp"
#define KEY_SETTING_ArmSocketPort   @"settingArmSocketPort"     //串口参数配置
#define DEFAULT_DELAY_MS            10000


//=====================================
@interface ViewController : NSViewController
//=====================================
{
    
@private
    IBOutlet NSView      *TABLE1;         //表格
    IBOutlet NSTextView  *LOGVIEW1;       //LOG显示窗口
    IBOutlet NSTextView  *ErrorIteam;     //显示所有NG的测试项名字
    //=====================Add by bill=================
    //------TOP----------
    IBOutlet NSTextField *TesterTitle;      //标题显示
    IBOutlet NSTextField *IndexMsg;         //错误信息
    IBOutlet NSTextField *TesterVersion;    //软件版本信息

    //------BL----------
    IBOutlet NSTextField *TestStatus;       //pass label
    IBOutlet NSTextField *SFCStatus;        //SFC状态信息
    IBOutlet NSTextField *PDCAStatus;       //PDCA状态信息
    IBOutlet NSTextField *TestModle;        //测试模式(A,AB,AAB,AAA)

    //------BM----------
    IBOutlet NSTextField *SN1Lable;          //显示当前测试产品的SN
    IBOutlet NSTextField *SN1;              //SN
    IBOutlet NSTextField *SB1;              //S_BUILD
    IBOutlet NSTextField *TestPassCount;    //测试Pass数量
    IBOutlet NSTextField *TestFailCount;    //测试Fail数量
    IBOutlet NSTextField *TestTotalCount;   //测试Total数量
    IBOutlet NSTextField *TestPassRate;     //测试PASS率
    IBOutlet NSTextField *TestFailRate;     //测试Fail率
    IBOutlet NSButton    *btCountReset;     //清除计数
    IBOutlet NSTextField *TestTime;         //测试时间
    //------BR----------
    IBOutlet NSTextField *Station;          //站别
    IBOutlet NSTextField *StationID;        //站别ID
    IBOutlet NSTextField *FixtureID;        //夹具ID
    IBOutlet NSTextField *LineNo;           //线别
    IBOutlet NSButton    *btStart;            //开始
    IBOutlet NSButton    *btStop;             //停止
    IBOutlet NSButton    *btPause;            //暂停
    IBOutlet NSButton    *btContinue;         //继续
    IBOutlet NSTextField *UserName;         //用户名

}
+(id)GetObject;
@property(readonly)Param* ex_param;

@property (assign) NSMutableDictionary * dicConfiguration;
@property (copy,readwrite) NSMutableDictionary * difConfigInstrument;   //用于仪器仪表的配置字典
@property (copy,readwrite) NSMutableArray *arrayInstrument;             //用于罗列仪器名字
@property (copy)   NSString * strCfgFile;
//================================================
@end