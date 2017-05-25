
//  ViewController.m
//  HowToWorks
//
//  Created by h on 17/3/16.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "ViewController.h"
#import "TestContext.h"
#import "AppDelegate.h"
#import "WindowController.h"
#import "BYDSFCManager.h"
#import "TestStep.h"
#import "CPACSocket.h"
#import "BYDSFCManager.h"
//================================================
NSString  *param_path=@"Param";
NSString  *plist_path=@"TestItem";
//================================================
@interface ViewController ()
{
    TestStep            *uploadingSFC;      //上传SFC
    //************ Device *************
    CPACSocket          *PACSocket;        //网口通讯
    BOOL                PACSocketConnectflag;//确认网口是否连接成功
    
    CTestContext        *ctestcontext;  //导入CTestContext类，便于使用字典
    
    Param               *param;         //配置文件参数
    
    Plist               *plist;         //plist配置文件
    NSMutableArray      *item;          //测试项目
    
    int                 chart_l_index;  //当前使用到的图标下标
    int                 chart_r_index;  //当前使用到的图标下标
    
    Table               *table;         //表格
    PDCA                *pdca;          //上传pdca
    FileTXT             *txt;           //生成本地TXT数据
    FileCSV             *csv;           //生成本地CSV数据报表
    Folder              *folder;        //创建文件夹对象
    TimeDate            *timedate;      //创建时间对象
    
    NSTimer             *timer;         //cycle time 计时器
    NSTimer             *humTimer;      //温湿度刷新定时器
    int                 ct_cnt;         //记录cycle time定时器中断的次数
    
    NSThread *myThread;                 //定义启动线程
    
    int                 index;          //过程控制下标
    int                 pause;          //暂停下标
    int                 time;           //过程延时，计数
    
    int                 item_index;     //测试流程下标
    int                 row_index;      //表格需要更新的行号
    
    NSString            *dutsn1;         //产品sn1
    NSString            *dutsn2;         //产品sn2
    NSString            *dutsn3;         //产品sn3
    NSString            *dutsn4;         //产品sn4
    
    NSString            *dutport;       //产品usb port
    
    NSString            *start_time;    //启动测试的时间
    NSString            *end_time;      //结束测试的时间
    NSString            *humitString;      //温度返回的数据
    NSMutableArray      *humitDataArray;    //用于保存csv
    
    BOOL                humitureCollect;  //温湿度连接
    BOOL                isTouch;          //是否已经完全接触
    NSMutableString     *humitureAppendString;  //温度拼接字符
 
    NSMutableString     *DataFromWindows;   //从windows端发过来的数据
    NSMutableString     *SFCBackString;     //SFC返回的字符串
    
    BOOL                only_test;          //调试用的
    //--------pass和fail数量信息统计--------
    int testpasscount;
    int testfailcount;
    int testtotalcount;
    int testpassrate;
    int testfailrate;
    
    NSMutableString *stationidstring;      //StationID
}
@end
//================================================
@implementation ViewController
//================================================
//=======网口相关===========
@synthesize dicConfiguration;
@synthesize difConfigInstrument;
@synthesize arrayInstrument;
@synthesize strCfgFile;
//=======网口相关===========

@synthesize ex_param  = param;
//================================================
#pragma mark - 隐藏（不关闭App）
-(IBAction)hideWindow:(id)sender{
    [[NSApplication sharedApplication] hide:self];
}
#pragma mark - 最小化
-(IBAction)miniaturizeWindow:(id)sender{
    [self.view.window miniaturize:self];
}
#pragma mark - 最大化
-(IBAction)zoomWindow:(id)sender{
    [self.view.window zoom:self];
}
//==================================================

- (void)viewDidLoad
{
    //获取stationID
    stationidstring = [[NSMutableString alloc] init];
    [stationidstring appendString:[self GetStrFromJson:@"SITE"]];
    [stationidstring appendString:[NSString stringWithFormat:@"_%@",[self GetStrFromJson:@"LINE_ID"]]];
    [stationidstring appendString:[NSString stringWithFormat:@"_%@",[self GetStrFromJson:@"STATION_NUMBER"]]];
    [stationidstring appendString:[NSString stringWithFormat:@"_%@",[self GetStrFromJson:@"STATION_TYPE"]]];
    //用于存windows端发过来的数据
    DataFromWindows = [[NSMutableString alloc] init];
    //SFC返回的字符串
    SFCBackString = [[NSMutableString alloc] init];
    
    dutsn1 = [[NSString alloc] init];         //产品sn1
    dutsn2 = [[NSString alloc] init];         //产品sn2
    dutsn3 = [[NSString alloc] init];         //产品sn3
    dutsn4 = [[NSString alloc] init];         //产品sn4
    //SFC
    uploadingSFC = [TestStep Instance];
    
    //网口
    PACSocket = new CPACSocket;
    
    //隐藏菜单
    [NSMenu setMenuBarVisible:YES];
    
    ctestcontext = new CTestContext();
    
    NSString *username= [ctestcontext->m_dicConfiguration valueForKey:kContextUserName];
    [UserName setStringValue:username];
    //--------------------------
    param = [[Param alloc]init];
    [param ParamRead:param_path];
    //--------------------------
    plist = [[Plist alloc]init];
    //--------------------------
    pdca=[[PDCA alloc]init];
    //--------------------------
    csv=[[FileCSV alloc]init];
    //--------------------------
    txt = [[FileTXT alloc]init];
    //--------------------------
    folder=[[Folder alloc]init];
    //--------------------------
    timedate=[[TimeDate alloc]init];
    
    //---------------设置版本号，标题等-----------
    [TesterTitle setStringValue:param.ui_title];           //设置title
    //--------------------------
    [TesterVersion setStringValue:param.tester_version];   //设置version
    //--------------------------
    [Station setStringValue:[self GetStrFromJson:@"STATION_NUMBER"]];   //设置station
    //--------------------------
    [StationID setStringValue:stationidstring];   //设置stationID
    //--------------------------
    [FixtureID setStringValue:param.fixtureID];   //设置fixtureID
    //--------------------------
    [LineNo setStringValue:[self GetStrFromJson:@"LINE_NUMBER"]];   //设置lineNO
    //--------------------------
    [ctestcontext->m_dicConfiguration setObject:param.csv_path forKey:kContextCsvPath];  //把csv路径存到字典里，在perferem类的初始化里需要用到
    [ctestcontext->m_dicConfiguration setObject:param.txt_path forKey:kContextTxtPath];  //把txt路径存到字典里，在perferem类的初始化里可能需要用到
    //--------------------------
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    //----------初始化界面信息----------------
    [self initUiMsg];
    
    [self InitialCtrls];
    
    //添加观察者(Add notification monitor)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnUiNotification:) name:kNotificationShowErrorTipOnUI object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OnUiNotification:) name:kNotificationPreferenceChange object:nil];
    
    //--------------------------
    myThread = [[NSThread alloc]                       //启动线程，进入测试流程
                initWithTarget:self
                selector:@selector(Action)
                object:nil];
    [myThread start];


    [super viewDidLoad];
}



-(void)viewWillDisappear
{
    //关闭程序时，做一些清理动作
    [NSApp terminate:self];
    //=================
    [myThread cancel];
    myThread = nil;
    
}


-(void)initUiMsg
{
    //-------------------------
    [SN1 setStringValue:@""];
    [SN1 setBackgroundColor:[NSColor blueColor]];
    [SN2 setStringValue:@""];
    [SN2 setBackgroundColor:[NSColor blueColor]];
    [SN3 setStringValue:@""];
    [SN3 setBackgroundColor:[NSColor blueColor]];
    [SN4 setStringValue:@""];
    [SN4 setBackgroundColor:[NSColor blueColor]];
    
    [SFC1 setStringValue:@""];
    [SFC1 setBackgroundColor:[NSColor blueColor]];
    [SFC2 setStringValue:@""];
    [SFC2 setBackgroundColor:[NSColor blueColor]];
    [SFC3 setStringValue:@""];
    [SFC3 setBackgroundColor:[NSColor blueColor]];
    [SFC4 setStringValue:@""];
    [SFC4 setBackgroundColor:[NSColor blueColor]];
    
    [PDCA1 setStringValue:@""];
    [PDCA1 setBackgroundColor:[NSColor blueColor]];
    [PDCA2 setStringValue:@""];
    [PDCA2 setBackgroundColor:[NSColor blueColor]];
    [PDCA3 setStringValue:@""];
    [PDCA3 setBackgroundColor:[NSColor blueColor]];
    [PDCA4 setStringValue:@""];
    [PDCA4 setBackgroundColor:[NSColor blueColor]];
    
    //--------------------------
    index=0;
    pause=0;
    row_index=0;
    time=0;
    ct_cnt=0;
    item_index=0;
    
    //--------pass和fail数量信息统计--------
    testpasscount = 0;
    testfailcount = 0;
    testtotalcount = 0;
    testpassrate = 0;
    testfailrate = 0;
    //------------初始化界面的一些信息--------------
    //--------------------------
    [TestPassCount setStringValue:@"0"];            //清空TestPass计数
    //--------------------------
    [TestFailCount setStringValue:@"0"];            //清空TestFail计数
    //--------------------------
    [TestTotalCount setStringValue:@"0"];           //清空TestTotal计数
    //--------------------------
    [TestPassRate setStringValue:@"***"];             //清空TestPassRate计数
    //--------------------------
    [TestFailRate setStringValue:@"***"];             //清空TestFailRate计数
    //--------------------------
    [TestTime setStringValue:@"0"];                 //清空TestTime计数
    //---------------------------
    [TestStatus setBackgroundColor:[NSColor blueColor]];
    [TestStatus setStringValue:@"Pause"];
    
    
    //定义默认选择的脚本,从配置文件中拿出来的
    if ([param.dut_type isEqualToString:@"Sensor Board"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Crown Flex"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Sensor Flex Sub"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:2] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Crown Rotation Sub"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:3] forKey:kContextscriptSelect];
    }
    else if ([param.dut_type isEqualToString:@"Test5"])
    {
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:4] forKey:kContextscriptSelect];
    }
    
    //判断用户权限，进行相关设置
    int AuthorityLevel = [[ctestcontext->m_dicConfiguration valueForKey:kContextAuthority] intValue];
    if (AuthorityLevel==0 )
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }
    else if (AuthorityLevel==1)
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:0] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }
    else if (AuthorityLevel==2)
    {
        //初始化字典变量
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckScanBarcode];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kConTextcheckSFC];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckPuddingPDCA];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:1] forKey:kContextcheckDebugOut];
    }

}

//初始化函数，用于初始化字典中的值，及设置配置界面的状态
-(void)InitialCtrls
{
    int SFCState = [[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
    if (SFCState)
    {
        [SFCStatus setStringValue:@"SFC ON"];
        [SFCStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [SFCStatus setStringValue:@"SFC OFF"];
        [SFCStatus setTextColor:[NSColor highlightColor]];
    }
    int PDCAState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
    if (PDCAState)
    {
        [PDCAStatus setStringValue:@"PDCA ON"];
        [PDCAStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [PDCAStatus setStringValue:@"PDCA OFF"];
        [PDCAStatus setTextColor:[NSColor highlightColor]];
    }
    
}
-(void)ReloadScript:(NSString*)dut_type
{
    //刷新测试项界面
    //--------------------------
    item  = [plist PlistRead:plist_path Key:dut_type];     //加载对应产品的测试项
    //--------------------------
    table = [table init:TABLE1 DisplayData:item];          //根据测试项初始化表格
    //--------------------------
}

//================================================
#pragma mark Notification
-(void)OnUiNotification:(NSNotification *)nf
{
    NSString *name = [nf name];
    if ([name isEqualToString:kNotificationShowErrorTipOnUI])
    {
        [self performSelectorOnMainThread:@selector(ShowErrorTipView:) withObject:[nf object] waitUntilDone:YES];
    }
    if ([name isEqualToString:kNotificationPreferenceChange]) {
        [self performSelectorOnMainThread:@selector(PreferenceChange:) withObject:[nf object] waitUntilDone:YES];
    }
}
-(void)ShowErrorTipView:(NSString*)Str
{
    [IndexMsg setStringValue:Str];
    [IndexMsg setHidden:NO];
}
-(void)PreferenceChange:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{

    int SFCState = [[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
        
    if (SFCState)
    {
        [SFCStatus setStringValue:@"SFC ON"];
        [SFCStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [SFCStatus setStringValue:@"SFC OFF"];
        [SFCStatus setTextColor:[NSColor highlightColor]];
    }
    int PDCAState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
    if (PDCAState)
    {
        [PDCAStatus setStringValue:@"PDCA ON"];
        [PDCAStatus setTextColor:[NSColor greenColor]];
    }
    else
    {
        [PDCAStatus setStringValue:@"PDCA OFF"];
        [PDCAStatus setTextColor:[NSColor highlightColor]];
    }
//    //根据所选的脚本，进行切换，以及本地plist文件的更改和重新读取。
//    if (0 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
//    {
//        NSString *Test1Name = @"Sensor Board";
//        [self ReloadScript:Test1Name];
//        [param ParamWrite:param_path Content:Test1Name Key:@"dut_type"];
//            }
//    else if (1 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
//    {
//        NSString *Test2Name = @"Crown Flex";
//        [self ReloadScript:Test2Name];
//        [param ParamWrite:param_path Content:Test2Name Key:@"dut_type"];
//    }
//    else if (2 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
//    {
//        NSString *Test3Name = @"Sensor Flex Sub";
//        [self ReloadScript:Test3Name];
//        [param ParamWrite:param_path Content:Test3Name Key:@"dut_type"];
//    }
//    else if (3 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
//    {
//        NSString *Test4Name = @"Crown Rotation Sub";
//        [self ReloadScript:Test4Name];
//        [param ParamWrite:param_path Content:Test4Name Key:@"dut_type"];
//    }
//    else if (4 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
//    {
//        NSString *Test5Name = @"Test5";
//        [self ReloadScript:Test5Name];
//        [param ParamWrite:param_path Content:Test5Name Key:@"dut_type"];
//    }
//    NSString *csvpathfromdic = [ctestcontext->m_dicConfiguration valueForKey:kContextCsvPath];
//    if (csvpathfromdic.length != 0)
//    {
//        [param ParamWrite:param_path Content:csvpathfromdic Key:@"csv_path"];
//    }
//    [param ParamRead:param_path];
//    [TesterTitle setStringValue:[NSString stringWithFormat:@"%@__%@",param.ui_title,param.dut_type]];           //设置title
//        
    });        
}
//================================================
+(id)GetObject
{
    return self;
}
//================================================
///**********************SN***********************/
//                    //收到的数据
//                    NSString *SN1 = @"SN:1234567,1:#";
//                    NSString *SN2 = @"SN:1234567,1:#";
//                    NSString *SN3 = @"SN:1234567,1:#";
//                    NSString *SN4 = @"SN:1234567,1:#";
//                    //要回复的数据
//                    NSString *RetSN1 = @"SN:1234567,1,OK:#";
//                    NSString *RetSN2 = @"SN:1234567,2,OK:#";
//                    NSString *RetSN3 = @"SN:1234567,3,OK:#";
//                    NSString *RetSN4 = @"SN:1234567,4,OK:#";
//
///**********************SFC***********************/
//                    //收到请求指令
//                    NSString *SFCQ = @"SFC:#";
//                    //发送SFC服务器返回的数据
//                    NSString *RetSFCQOK = @"SFC:SN,OK,errcode:NULL:#";  //OK
//                    NSString *RetSFCQNG = @"SFC:SN,NG,errcode:Go to Next Station";//NG
//
///**********************PDCA***********************/
//                    //收到数据
//NSString *PDCAData = @"PDCA(类型):1234567(条码),1(第几个产品),0.1(数值1),0.21(数值2),0.11(数值3),0.15(数值4),8.2(数值5):#";  //OK
//                    NSString *PDCADataNULL = @"PDCA:1234567,1,NULL,NULL,NULL,NULL,NULL:#";    //NG
//PDCA:NULL,1,-1,-1,-1,-1,-1:NULL,2,-1,-1,-1,-1,-1:NULL,3,-1,-1,-1,-1,-1:NULL,4,-1,-1,-1,-1,-1:#
-(void)Action
{
    @autoreleasepool
    {
        //隐藏菜单
        [NSMenu setMenuBarVisible:NO];
        while([[NSThread currentThread] isCancelled] == NO)
        {
#pragma mark index=0 与windows端创建连接
            if (0==index)
            {
                if (![[IndexMsg stringValue]isEqualToString:@"Index:0,与windows端创建连接"])
                {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [IndexMsg setBackgroundColor:[NSColor redColor]];
                     });
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:0,与windows端创建连接"]];
                }
                sleep(0.1);
                ct_cnt = 0;
                [self StartTimer:0.5];
                PACSocketConnectflag = PACSocket->CreateTCPClient([[NSString stringWithFormat:@"Macmini"] UTF8String], [param.IP_MacWin UTF8String], [param.Port_MacWin intValue]);
                
                if (PACSocketConnectflag)
                {
                    NSLog(@"网络连接成功!!!!!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [IndexMsg setBackgroundColor:[NSColor greenColor]];
                    });
                    index=1;
                }
                else
                {
                    [NSThread sleepForTimeInterval:2];
                    NSLog(@"网络连接失败,请检查网络!!!!!!");
                }
            }
#pragma mark index=1 读取数据
            if (1==index)
            {
                if (![[IndexMsg stringValue]isEqualToString:@"Index:1,读取数据"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:1,读取数据"]];
                }
                sleep(0.1);
                
                NSString *str = [NSString stringWithUTF8String:PACSocket->TCPReadString()];
                if ([str length]>0)
                {
                    //判断指令最后位是否为协定的字符 #
                    if ([str containsString:@"#"])
                    {
                        NSRange RanngeReplace = [str rangeOfString:@"#"];
                        str = [str substringToIndex:RanngeReplace.location+1];
                        
                        [DataFromWindows appendString:str];
                        NSLog(@"读取数据成功:%@",str);
                        index = 2;
                    }
                    else
                    {
                        NSLog(@"指令最后位格式错误，未包含#");
                    }
                }
                else
                {
                    [NSThread sleepForTimeInterval:0.2];
                }
            }
#pragma mark index=2 处理数据
            if (2==index)
            {
                if (![[IndexMsg stringValue]isEqualToString:@"Index:2,处理数据"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:2,处理数据"]];
                }
                sleep(0.1);
                NSArray *flowArray = [DataFromWindows componentsSeparatedByString:@":"];
                NSString *flowStr = flowArray[0];
//处理SN
                if ([flowStr isEqualToString:@"SN"])
                {
                    if ([flowArray count]==3)
                    {
                        //处理界面上的SN
                        if([flowArray[1] length]>0)
                        {
                            //再次分割字符串
                            NSMutableString *snStr = [[NSMutableString alloc] init];
                            [snStr appendString:flowArray[1]];
                            NSArray *snArray = [snStr componentsSeparatedByString:@","];
                            if ([snArray[1] isEqualToString:@"1"])
                            {
                                dutsn1 = snArray[0];
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [SN1 setStringValue:snArray[0]];
                                     [SFC1 setStringValue:@""];
                                     [SFC1 setBackgroundColor:[NSColor blueColor]];
                                     [PDCA1 setStringValue:@""];
                                     [PDCA1 setBackgroundColor:[NSColor blueColor]];
                                 });
                                //处理SN
                                NSString *RetSN = [NSString stringWithFormat:@"SN:%@,1,OK:#",dutsn1];
                                PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                            }
                            else if ([snArray[1] isEqualToString:@"2"])
                            {
                                dutsn2 = snArray[0];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SN2 setStringValue:snArray[0]];
                                    [SFC2 setStringValue:@""];
                                    [SFC2 setBackgroundColor:[NSColor blueColor]];
                                    [PDCA2 setStringValue:@""];
                                    [PDCA2 setBackgroundColor:[NSColor blueColor]];
                                });
                                //处理SN
                                NSString *RetSN = [NSString stringWithFormat:@"SN:%@,2,OK:#",dutsn2];
                                PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                            }
                            else if ([snArray[1] isEqualToString:@"3"])
                            {
                                dutsn3 = snArray[0];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SN3 setStringValue:snArray[0]];
                                    [SFC3 setStringValue:@""];
                                    [SFC3 setBackgroundColor:[NSColor blueColor]];
                                    [PDCA3 setStringValue:@""];
                                    [PDCA3 setBackgroundColor:[NSColor blueColor]];
                                });
                                //处理SN
                                NSString *RetSN = [NSString stringWithFormat:@"SN:%@,3,OK:#",dutsn3];
                                PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                            }
                            else if ([snArray[1] isEqualToString:@"4"])
                            {
                                dutsn4 = snArray[0];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SN4 setStringValue:snArray[0]];
                                    [SFC4 setStringValue:@""];
                                    [SFC4 setBackgroundColor:[NSColor blueColor]];
                                    [PDCA4 setStringValue:@""];
                                    [PDCA4 setBackgroundColor:[NSColor blueColor]];
                                });
                                //处理SN
                                NSString *RetSN = [NSString stringWithFormat:@"SN:%@,4,OK:#",dutsn4];
                                PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                            }
                        }
                    }
                    else
                    {
                        NSLog(@"指令格式错误");
                        //处理SN
                        NSString *RetSN = @"SN:cmd error:#";
                        PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                    }
                    
                }
//处理SFC
                else if ([flowStr isEqualToString:@"SFC"])
                {
                    //UUT1
                    if ([dutsn1 isEqualToString:@"NULL"])
                    {
                        NSLog(@"第一个托盘上没有产品");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SFC1 setStringValue:@"NULL"];
                            [SFC1 setBackgroundColor:[NSColor blueColor]];
                        });
                    }
                    else
                    {
                        uploadingSFC.strSN =dutsn1;
                        BOOL IfSFCOK = [uploadingSFC StepSFC_CheckUploadSN:YES];
                        NSString *SFCErreTypeStr = [self ReturnSFCErrorTypeStr];
                        [SFCBackString appendString:[NSString stringWithFormat:@"SFC:%@",dutsn1]];
                        if (IfSFCOK)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC1 setStringValue:SFCErreTypeStr];
                                [SFC1 setBackgroundColor:[NSColor greenColor]];
                            });
                            [SFCBackString appendString:@",OK"];
                        }
                        else
                        {

                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC1 setStringValue:SFCErreTypeStr];
                                [SFC1 setBackgroundColor:[NSColor redColor]];
                            });
                            [SFCBackString appendString:@",NG"];
                        }
                        [SFCBackString appendString:[NSString stringWithFormat:@",%@:",SFCErreTypeStr]];
                    }

                    //UUT2
                    if ([dutsn2 isEqualToString:@"NULL"])
                    {
                        NSLog(@"第一个托盘上没有产品");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SFC2 setStringValue:@"NULL"];
                            [SFC2 setBackgroundColor:[NSColor blueColor]];
                        });
                    }
                    else
                    {
                        uploadingSFC.strSN =dutsn2;
                        BOOL IfSFCOK = [uploadingSFC StepSFC_CheckUploadSN:YES];
                        NSString *SFCErreTypeStr = [self ReturnSFCErrorTypeStr];
                        [SFCBackString appendString:dutsn2];
                        if (IfSFCOK)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC2 setStringValue:SFCErreTypeStr];
                                [SFC2 setBackgroundColor:[NSColor greenColor]];
                            });
                            [SFCBackString appendString:@",OK"];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC2 setStringValue:SFCErreTypeStr];
                                [SFC2 setBackgroundColor:[NSColor redColor]];
                            });
                            [SFCBackString appendString:@",NG"];
                        }
                        [SFCBackString appendString:[NSString stringWithFormat:@",%@:",SFCErreTypeStr]];
                    }
                    //UUT3
                    if ([dutsn3 isEqualToString:@"NULL"])
                    {
                        NSLog(@"第一个托盘上没有产品");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SFC3 setStringValue:@"NULL"];
                            [SFC3 setBackgroundColor:[NSColor blueColor]];
                        });
                    }
                    else
                    {
                        uploadingSFC.strSN =dutsn3;
                        BOOL IfSFCOK = [uploadingSFC StepSFC_CheckUploadSN:YES];
                        NSString *SFCErreTypeStr = [self ReturnSFCErrorTypeStr];
                        [SFCBackString appendString:dutsn3];
                        if (IfSFCOK)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC3 setStringValue:SFCErreTypeStr];
                                [SFC3 setBackgroundColor:[NSColor greenColor]];
                            });
                            [SFCBackString appendString:@",OK"];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC3 setStringValue:SFCErreTypeStr];
                                [SFC3 setBackgroundColor:[NSColor redColor]];
                            });
                            [SFCBackString appendString:@",NG"];
                        }
                        [SFCBackString appendString:[NSString stringWithFormat:@",%@:",SFCErreTypeStr]];
                    }
                    
                    //UUT4
                    if ([dutsn4 isEqualToString:@"NULL"])
                    {
                        NSLog(@"第一个托盘上没有产品");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [SFC4 setStringValue:@"NULL"];
                            [SFC4 setBackgroundColor:[NSColor blueColor]];
                        });
                    }
                    else
                    {
                        uploadingSFC.strSN =dutsn4;
                        BOOL IfSFCOK = [uploadingSFC StepSFC_CheckUploadSN:YES];
                        NSString *SFCErreTypeStr = [self ReturnSFCErrorTypeStr];
                        [SFCBackString appendString:dutsn4];
                        if (IfSFCOK)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC4 setStringValue:@"SFC_OK"];
                                [SFC4 setBackgroundColor:[NSColor greenColor]];
                            });
                            [SFCBackString appendString:@",OK"];
                        }
                        else
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [SFC4 setStringValue:SFCErreTypeStr];
                                [SFC4 setBackgroundColor:[NSColor redColor]];
                            });
                            [SFCBackString appendString:@",NG"];
                        }
                        [SFCBackString appendString:[NSString stringWithFormat:@",%@:#",SFCErreTypeStr]];
                    }
                    //回复SFC请求的结果
                    NSLog(@"SFC回复的数据: %@",SFCBackString);
                    PACSocket->TCPSendString((char*)[SFCBackString UTF8String]);
                    
                }
//上传PDCA和SFC的结果     PDCA:NULL,1,-1,-1,-1,-1,-1:NULL,2,-1,-1,-1,-1,-1:NULL,3,-1,-1,-1,-1,-1:NULL,4,-1,-1,-1,-1,-1:#
                else if ([flowStr isEqualToString:@"PDCA"])
                {
                    //处理PDCA
                    if ([flowArray count]==6)
                    {
                        [self UploadSFC_PDCAData:flowArray[1]];
                        [self UploadSFC_PDCAData:flowArray[2]];
                        [self UploadSFC_PDCAData:flowArray[3]];
                        [self UploadSFC_PDCAData:flowArray[4]];
                        //处理SN
                        NSString *RetSN = @"PDCA:OK:#";
                        PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                    }
                    else
                    {
                        NSLog(@"指令格式错误");
                        //处理SN
                        NSString *RetSN = @"SN:cmd error:#";
                        PACSocket->TCPSendString((char*)[RetSN UTF8String]);
                    }
                    
                }
                index = 3;
            }
#pragma mark index=3 清除buffer，返回读取数据
            if (3==index)
            {
                if (![[IndexMsg stringValue]isEqualToString:@"Index:3,清除buffer"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:3,清除buffer"]];
                }
                sleep(0.1);
                [DataFromWindows setString:@""];
                [SFCBackString setString:@""];
//                dutsn1 = @"";
//                dutsn2 = @"";
//                dutsn3 = @"";
//                dutsn4 = @"";
                index = 1;
                
                //清空log显示
                if ([[LOGVIEW1 string] length]>500000)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSRange range;
                        range = NSMakeRange(0, [[LOGVIEW1 string] length]);
                        [LOGVIEW1 replaceCharactersInRange:range withString:@""];
                        NSLog(@"Log字符串超过100000字节，已清掉");
                    });
                }

            }
            
        }

        
    }
}

-(void)UploadSFC_PDCAData:(NSString*)data
{
    //处理PDCA
    if(data.length>0)
    {
        //再次分割字符串
        //UUT1
        NSMutableString *snStr = [[NSMutableString alloc] init];
        [snStr appendString:data];
        NSArray *snArray = [snStr componentsSeparatedByString:@","];
        
        if ([snArray count]==7)
        {
            if ([snArray[0] isEqualToString:@"NULL"])
            {
                NSLog(@"获取SN:NULL,不上传PDCA");
                //刷新界面
                if ([snArray[1] isEqualToString:@"1"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA1 setStringValue:@"NULL"];
                        [PDCA1 setBackgroundColor:[NSColor blueColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"2"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA2 setStringValue:@"NULL"];
                        [PDCA2 setBackgroundColor:[NSColor blueColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"3"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA3 setStringValue:@"NULL"];
                        [PDCA3 setBackgroundColor:[NSColor blueColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"4"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA4 setStringValue:@"NULL"];
                        [PDCA4 setBackgroundColor:[NSColor blueColor]];
                    });
                }
            }
            else
            {
                //判断产品是否Pass
                BOOL Gap1PassOrFail = ([snArray[2] floatValue]>=[param.Gap1LowerLimit floatValue])&&([snArray[2] floatValue]<=[param.Gap1UpperLimit floatValue])?YES:NO;
                BOOL Gap2PassOrFail = ([snArray[3] floatValue]>=[param.Gap2LowerLimit floatValue])&&([snArray[3] floatValue]<=[param.Gap2UpperLimit floatValue])?YES:NO;
                BOOL Gap3PassOrFail = ([snArray[4] floatValue]>=[param.Gap3LowerLimit floatValue])&&([snArray[4] floatValue]<=[param.Gap3UpperLimit floatValue])?YES:NO;
                BOOL Gap4PassOrFail = ([snArray[5] floatValue]>=[param.Gap4LowerLimit floatValue])&&([snArray[5] floatValue]<=[param.Gap4UpperLimit floatValue])?YES:NO;
                BOOL OHMPassOrFail = ([snArray[6] floatValue]>=[param.OHMLowerLimit floatValue])&&([snArray[6] floatValue]<=[param.OHMUpperLimit floatValue])?YES:NO;
                BOOL PF = Gap1PassOrFail&&Gap2PassOrFail&&Gap3PassOrFail&&Gap4PassOrFail&&OHMPassOrFail?YES:NO;
                
                NSMutableString *SFCErrorMsg = [[NSMutableString alloc] init];
                NSMutableString *SFCErrorItem = [[NSMutableString alloc] init];
                //添加SFC上传的相关信息
                uploadingSFC.strSN =snArray[0];
                if (!Gap1PassOrFail)
                {
                    [SFCErrorItem appendString:@"Gap1"];
                    [SFCErrorMsg appendString:@"EA-1"];
                }
                if (!Gap2PassOrFail)
                {
                    if (SFCErrorItem.length>0)
                    {
                        [SFCErrorItem appendString:@",Gap2"];
                        [SFCErrorMsg appendString:@",EA-2"];
                    }
                    else
                    {
                        [SFCErrorItem appendString:@"Gap2"];
                        [SFCErrorMsg appendString:@"EA-2"];
                    }

                }
                if (!Gap3PassOrFail)
                {
                    if (SFCErrorItem.length>0)
                    {
                        [SFCErrorItem appendString:@",Gap3"];
                        [SFCErrorMsg appendString:@",EA-3"];
                    }
                    else
                    {
                        [SFCErrorItem appendString:@"Gap3"];
                        [SFCErrorMsg appendString:@"EA-3"];
                    }

                }
                if (!Gap4PassOrFail)
                {
                    if (SFCErrorItem.length>0)
                    {
                        [SFCErrorItem appendString:@",Gap4"];
                        [SFCErrorMsg appendString:@",EA-4"];
                    }
                    else
                    {
                        [SFCErrorItem appendString:@"Gap4"];
                        [SFCErrorMsg appendString:@"EA-4"];
                    }
                }
                if (!OHMPassOrFail)
                {
                    if (SFCErrorItem.length>0)
                    {
                        [SFCErrorItem appendString:@",OHM"];
                        [SFCErrorMsg appendString:@",EA-5"];
                    }
                    else
                    {
                        [SFCErrorItem appendString:@"OHM"];
                        [SFCErrorMsg appendString:@"EA-5"];
                    }

                }
                if (PF)
                {
                    
                    [uploadingSFC StepSFC_CheckUploadResult:YES andIsTestPass:YES andFailItem:nil andFailMessage:nil];
                    //处理界面计数
                    dispatch_async(dispatch_get_main_queue(), ^{
                        testpasscount = testpasscount+1;
                        testtotalcount = testtotalcount+1;
                        testpassrate = testpasscount/testtotalcount;
                        [TestPassCount setStringValue:[NSString stringWithFormat:@"%d",testpasscount]];
                        [TestTotalCount setStringValue:[NSString stringWithFormat:@"%d",testtotalcount]];
                        [TestPassRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testpasscount/(double)testtotalcount*100]];
                        //同事更新fail的统计数据
                        testfailrate = testfailcount/testtotalcount;
                        [TestFailCount setStringValue:[NSString stringWithFormat:@"%d",testfailcount]];
                        [TestFailRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testfailcount/(double)testtotalcount*100]];
                    });
                    
                }
                else
                {
                    [uploadingSFC StepSFC_CheckUploadResult:YES andIsTestPass:NO andFailItem:SFCErrorItem andFailMessage:SFCErrorMsg];
                    
                    //处理界面计数
                    dispatch_async(dispatch_get_main_queue(), ^{
                        testfailcount = testfailcount+1;
                        testtotalcount = testtotalcount+1;
                        testfailrate = testfailcount/testtotalcount;
                        [TestFailCount setStringValue:[NSString stringWithFormat:@"%d",testfailcount]];
                        [TestTotalCount setStringValue:[NSString stringWithFormat:@"%d",testtotalcount]];
                        [TestFailRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testfailcount/(double)testtotalcount*100]];
                        //同事统计Pass的统计数据
                        testpassrate = testpasscount/testtotalcount;
                        [TestPassCount setStringValue:[NSString stringWithFormat:@"%d",testpasscount]];
                        [TestPassRate setStringValue:[NSString stringWithFormat:@"%.2f%%",(double)testpasscount/(double)testtotalcount*100]];
                    });
                }
                
                //处理PDCA的相关信息
                [pdca PDCA_GetStartTime];
                [pdca PDCA_Init:snArray[0] SW_name:param.sw_name SW_ver:param.sw_ver];
                
                [pdca PDCA_UploadValue:@"Gap1"
                                 Lower:param.Gap1LowerLimit
                                 Upper:param.Gap1UpperLimit
                                  Unit:param.Gap1Unit
                                 Value:snArray[2]
                             Pass_Fail:Gap1PassOrFail
                 ];
                [pdca PDCA_UploadValue:@"Gap2"
                                 Lower:param.Gap2LowerLimit
                                 Upper:param.Gap2UpperLimit
                                  Unit:param.Gap2Unit
                                 Value:snArray[3]
                             Pass_Fail:Gap2PassOrFail
                 ];
                [pdca PDCA_UploadValue:@"Gap3"
                                 Lower:param.Gap3LowerLimit
                                 Upper:param.Gap3UpperLimit
                                  Unit:param.Gap3Unit
                                 Value:snArray[4]
                             Pass_Fail:Gap3PassOrFail
                 ];
                [pdca PDCA_UploadValue:@"Gap4"
                                 Lower:param.Gap4LowerLimit
                                 Upper:param.Gap4UpperLimit
                                  Unit:param.Gap4Unit
                                 Value:snArray[5]
                             Pass_Fail:Gap4PassOrFail
                 ];
                [pdca PDCA_UploadValue:@"OHM"
                                 Lower:param.OHMLowerLimit
                                 Upper:param.OHMUpperLimit
                                  Unit:param.OHMUnit
                                 Value:snArray[6]
                             Pass_Fail:OHMPassOrFail
                 ];
                [pdca PDCA_GetEndTime];
                [pdca PDCA_Upload:PF];     //上传汇总结果
                //刷新界面
                if ([snArray[1] isEqualToString:@"1"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA1 setStringValue:@"upload ok"];
                        [PDCA1 setBackgroundColor:[NSColor greenColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"2"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA2 setStringValue:@"upload ok"];
                        [PDCA2 setBackgroundColor:[NSColor greenColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"3"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA3 setStringValue:@"upload ok"];
                        [PDCA3 setBackgroundColor:[NSColor greenColor]];
                    });
                }
                else if ([snArray[1] isEqualToString:@"4"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [PDCA4 setStringValue:@"upload ok"];
                        [PDCA4 setBackgroundColor:[NSColor greenColor]];
                    });
                }
                
            }
        }
        else
        {
            NSLog(@"指令格式错误!!!");
            //处理SN
            NSString *RetSN = @"SN:cmd error:#";
            PACSocket->TCPSendString((char*)[RetSN UTF8String]);
        }
    }

}


-(NSString *)ReturnSFCErrorTypeStr
{
    NSString *_strErrorMessage = @"";
    switch ([[BYDSFCManager Instance] SFCErrorType])
    {

        case SFC_ErrorNet:_strErrorMessage=@"ErrorNet";
            break;
        case SFC_TimeOut_Error:_strErrorMessage=@"SFC_Time_Out";
            break;
        case SFC_Fail:_strErrorMessage=[ctestcontext->m_dicConfiguration objectForKey:kContextSFCErrorMsg];
            break;
        case SFC_Success:
        {
            _strErrorMessage=@"SFC_OK";
        }
            break;
        case SFC_Default:
        default:_strErrorMessage=@"OtherError";
            break;
    }
    return _strErrorMessage;
};


//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{
    BOOL PF = YES;    //所有测试项是否pass
    
    [pdca PDCA_Init:dutsn1 SW_name:param.sw_name SW_ver:param.sw_ver];   //上传sn，sw_name,sw_ver
    
//    [pdca PDCA_AddAttribute:sbuild FixtureID:param.fixture_id];         //上传s_build，fixture_id
    
    for(int i=0;i<[item count];i++)
    {
        Item *testitem=item[i];
        
        if(testitem.isNeedTest)  //需要测试的才需要上传
        {
            Item *testitem = item[i];
            
            if((testitem.isNeedShow == YES)&&(testitem.isNeedTest))    //需要显示并且需要测试的才上传
            {
                if(testitem.isPdcaValue)   //如果测试结果是数值
                {
                    BOOL pass_fail=YES;
                    
                    if( ![testitem.testResult isEqualToString:@"PASS"] )
                    {
                        pass_fail = NO;
                        
                        PF = NO;
                    }
                    
                    [pdca PDCA_UploadValue:testitem.testName
                                     Lower:testitem.testLowerLimit
                                     Upper:testitem.testUpperLimit
                                      Unit:testitem.testValueUnit
                                     Value:testitem.testValue
                                 Pass_Fail:pass_fail
                     ];
                }
                else                       //如果测试结果只有pass或fail
                {
                    if([testitem.testResult isEqualToString:@"PASS"])
                    {
                        [pdca PDCA_UploadPass:testitem.testName];
                    }
                    else
                    {
                        [pdca PDCA_UploadFail:testitem.testName Message:testitem.testMessage];
                        PF = NO;
                    }
                }
            }
        }
    }
    
    [pdca PDCA_Upload:PF];     //上传汇总结果
}
//================================================
//保存温湿度csv
//================================================
-(void)SaveHumitureCSV:(BOOL)need_title
{
    NSMutableString *str = [[NSMutableString alloc] init];
    for (int i=0; i<[humitDataArray count]; i=i+4) {
        [str appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,\n",humitDataArray[i],humitDataArray[i+1],humitDataArray[i+2],humitDataArray[i+3]]];
    }
    NSString * title = @"SN,StartTime,StopTime,Value\n";
    if(need_title == YES)[csv CSV_Write:title];
    [humitDataArray removeAllObjects];
    [csv CSV_Write:str];
}
//================================================
//保存csv
//================================================
-(void)SaveCSV:(BOOL)need_title
{
    BOOL PF = YES;         //所有测试项是否pass
    
    NSString *title=@"";
    NSString *line=@"";
    
    title = @"SN, SW Name, SW Ver, Fixture_ID, Start Time, End Time,";

    line = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@,",dutsn1, param.sw_name, param.sw_ver, param.fixture_id, start_time, end_time];
    
    
    for(int i=0;i<[item count];i++)
    {
        Item *testitem=item[i];
        
        if(testitem.isNeedTest)  //需要测试的才需要上传
        {
            Item *testitem = item[i];
            
            if((testitem.isNeedShow == YES)&&(testitem.isNeedTest))    //需要显示并且需要测试的才保存
            {
                if(testitem.isPdcaValue)   //如果测试结果是数值
                {
                    BOOL pass_fail=YES;
                    
                    if( ![testitem.testResult isEqualToString:@"PASS"] )
                    {
                        pass_fail = NO;
                        
                        PF = NO;
                    }
                    title = [title stringByAppendingString:@"Iteam Name"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Value"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Unit"];
                    title = [title stringByAppendingString:@","];
                    
                    line=[line stringByAppendingString:testitem.testName];
                    line=[line stringByAppendingString:@","];
                    line=[line stringByAppendingString:testitem.testValue];
                    line=[line stringByAppendingString:@","];
                    line=[line stringByAppendingString:testitem.testValueUnit];
                    line=[line stringByAppendingString:@","];

                    
                }
                else                       //如果测试结果只有pass或fail
                {
                    title = [title stringByAppendingString:@"Iteam Name"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Value"];
                    title = [title stringByAppendingString:@","];
                    title = [title stringByAppendingString:@"Item Unit"];
                    title = [title stringByAppendingString:@","];
                    
                    
                    line=[line stringByAppendingString:testitem.testName];
                    line=[line stringByAppendingString:@","];
                    
                    if([testitem.testResult isEqualToString:@"PASS"])
                    {
                        line=[line stringByAppendingString:testitem.testResult];
                        line=[line stringByAppendingString:@","];
                    }
                    else
                    {
                        line=[line stringByAppendingString:testitem.testResult];
                        line=[line stringByAppendingString:@","];
                        PF = NO;
                    }
                }
            }
        }
    }
    
    title = [title stringByAppendingString:@"Test Result"];
    title = [title stringByAppendingString:@","];
    title=[title stringByAppendingString:@""];
    title=[title stringByAppendingString:@"\n"];
    
    NSString *test_result;
    if (PF)
    {
        test_result = @"PASS";
    }
    else
    {
        test_result = @"FAIL";
    }
    line=[line stringByAppendingString:test_result];
    line=[line stringByAppendingString:@"\n"];
    line=[line stringByAppendingString:@""];
    line=[line stringByAppendingString:@"\n"];   //end_time
    if(need_title == YES)[csv CSV_Write:title];
    
    [csv CSV_Write:line];
}
//================================================
// 开始定时器
//================================================
-(void)StartTimer:(float)seconds
{
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         
            dispatch_async(dispatch_get_main_queue(), ^{
            //定义一个NSTimer
            timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                     target:self
                                                   selector:@selector(IrqTimer:)
                                                   userInfo:nil
                                                    repeats:YES
                     ];
            });
        
    });
    
}
//================================================
// 停止定时器
//================================================
-(void)StopTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(timer != nil){
            [timer invalidate];// 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
        }
    });
}
//================================================
// 定时器回调函数，刷新cycle time界面显示
//================================================
-(void)IrqTimer:(NSTimer *)timer
{
    ct_cnt = ct_cnt + 1;
    
    NSString *strtime=[[NSString alloc]initWithFormat:@"%0.1f",ct_cnt*0.1];
    
    [TestTime setStringValue:[NSString stringWithFormat:@"%@  s",strtime]];
    
    BOOL ifconnect = PACSocket->getConnectState();
    if (!ifconnect)
    {
        index = 0;
    }
    
}


//================================================
- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}
//================================================
- (void)redirectNotificationHandle:(NSNotification *)nf{
    if (1 == [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckDebugOut] intValue])
    {
        NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if(LOGVIEW1 != nil)
        {
            NSRange range;
            range = NSMakeRange ([[LOGVIEW1 string] length], 0);
            [LOGVIEW1 replaceCharactersInRange: range withString: str];
            [LOGVIEW1 scrollRangeToVisible:range];
        }
        
        [[nf object] readInBackgroundAndNotify];
    }
    else
    {        
        [[nf object] readInBackgroundAndNotify];
    }
}
//================================================
- (void)redirectSTD:(int )fd{
    
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    
    [pipeReadHandle readInBackgroundAndNotify];
}
//================================================

-(IBAction)btstart:(id)sender
{
    SN1.editable = YES;
    sleep(0.5);
    NSLog(@"start button is pressed!!!!");
    //隐藏菜单
    [NSMenu setMenuBarVisible:NO];
    if(myThread != nil)
    {
        NSLog(@"测试已经开始了！！！！");
    }
    else
    {
        NSLog(@"重新开启测试！！！！");
        dispatch_async(dispatch_get_main_queue(), ^{
            //--------------------------
            item  = [plist PlistRead:plist_path Key:param.dut_type];     //加载对应产品的测试项
            //--------------------------
            //table = [table init:TABLE1 DisplayData:item];    //根据测试项初始化表格
            [table ClearTable];
            
            [self StopTimer];
            item_index = 0;
            row_index = 0;
            ct_cnt = 0;
            index = 1;
            [SN1 setStringValue:@""];
            //配置完相关配置后，再开启线程
            myThread = [[NSThread alloc]                       //启动线程，进入测试流程
                        initWithTarget:self
                        selector:@selector(Action)
                        object:nil];
            [myThread start];
        });
        
        
    }
    
}


-(IBAction)btstop:(id)sender
{
    NSLog(@"stop button is pressed!!!!");
    SN1.editable = NO;
    sleep(0.5);
    if(myThread != nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self StopTimer];
            [SN1 setStringValue:@""];
            //先把线程停掉，再进行相关配置
            [myThread cancel];
            myThread = nil;
            if(index != 9999)
            {
                [ctestcontext->m_dicConfiguration setObject:[NSNumber numberWithInt:index] forKey:kContextindexOld];
            }
            index = 9999;
            //显示菜单
            [NSMenu setMenuBarVisible:YES];
            
        });
        
        NSLog(@"当前线程已经被取消了!!!!");
        
    }
    else
    {
        NSLog(@"测试已经取消了");
    }
    
}


//更新状态栏的状态信息及背景色
-(void)UpdateLableStatus:(NSString*) strDisplayValue andColor:(NSColor*)color
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [IndexMsg setStringValue:strDisplayValue];
        [IndexMsg setBackgroundColor:color];
    });
}




-(IBAction)btpause:(id)sender
{
    NSLog(@"pause button is pressed!!!!");
}
-(IBAction)btcontinue:(id)sender
{
    NSLog(@"continue button is pressed!!!!");
}
-(IBAction)btcountreset:(id)sender
{
    NSLog(@"countreset button is pressed!!!");
    testpasscount = 0;
    testfailcount = 0;
    testtotalcount = 0;
    testpassrate = 0;
    testfailrate = 0;
    //--------------------------
    [TestPassCount setStringValue:@"0"];            //清空TestPass计数
    //--------------------------
    [TestFailCount setStringValue:@"0"];            //清空TestFail计数
    //--------------------------
    [TestTotalCount setStringValue:@"0"];           //清空TestTotal计数
    //--------------------------
    [TestPassRate setStringValue:@"***"];             //清空TestPassRate计数
    //--------------------------
    [TestFailRate setStringValue:@"***"];             //清空TestFailRate计数
    
}

//从Json文件中读取键值
-(NSString *)GetStrFromJson:(NSString *)Key
{
    
    NSString * str = nil;
    NSString * ghStationInfoContent = [NSString stringWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"
                                                                encoding:NSUTF8StringEncoding error:nil];
    NSData * ghStationInfoData = [ghStationInfoContent dataUsingEncoding:NSUTF8StringEncoding];
    if (ghStationInfoData)
    {
        NSDictionary * ghStationInfo = [NSJSONSerialization JSONObjectWithData:ghStationInfoData
                                                                       options:0
                                                                         error:nil];
        NSDictionary * ghInfo = [ghStationInfo objectForKey:@"ghinfo"];
        if (ghInfo)
        {
            str = [ghInfo objectForKey:Key];
        }
    }
    return str;
}


@end
//================================================