
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
#import "SerialPort.h"
#import "AgilentDevice.h"
#import "KeithleyDevice.h"
#import "BYDSFCManager.h"
#import "TestStep.h"
#import "Agilent3458A.h"
#import "Agilent33210A.h"

//================================================
NSString  *param_path=@"Param";
NSString  *plist_path=@"TestItem";
NSString  *tmconfig_path=@"TmConfig";

//================================================
@interface ViewController ()
{
    //************ Device *************
    SerialPort          * serialPort;
    SerialPort          * fixtureSerial;   //治具串口
    SerialPort          * humitureSerial;  //温湿度串口
    KeithleyDevice      * keithleySerial;  //泰克调试
    Agilent3458A        * agilent3458A;    //安捷伦万用表
    Agilent33210A       * agilent33210A;   //波形发生器
    
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
    NSString            *dutsn;         //产品sn
    NSString            *sbuild;        //产品sbuild
    NSString            *dutport;       //产品usb port
    
    NSString            *start_time;    //启动测试的时间
    NSString            *end_time;      //结束测试的时间
    NSString            *humitString;      //温度返回的数据
    NSMutableArray      *humitDataArray;    //用于保存csv
    
    BOOL                humitureCollect;  //温湿度连接
    BOOL                isTouch;          //是否已经完全接触
    NSMutableString  * humitureAppendString;  //温度拼接字符
 
    BOOL                only_test;          //调试用的
    //--------pass和fail数量信息统计--------
    int testpasscount;
    int testfailcount;
    int testtotalcount;
    int testpassrate;
    int testfailrate;
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
    humitDataArray = [[NSMutableArray alloc] init];
    [[BYDSFCManager Instance]setStrSN:dutsn];//赋值
    //隐藏菜单
    [NSMenu setMenuBarVisible:YES];
    
    ctestcontext = new CTestContext();
    //创建仪器仪表对象
    difConfigInstrument = [[NSMutableDictionary alloc] init];
    
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
    //--------------------------
    fixtureSerial=[[SerialPort alloc] init];
    //--------------------------
    keithleySerial=[[KeithleyDevice alloc] init];
    //--------------------------
    humitureSerial=[[SerialPort alloc]init];
    //--------------------------
    agilent33210A =[[Agilent33210A alloc] init];
    //--------------------------
    agilent3458A =[[Agilent3458A alloc] init];
    
    humitString=@"";

    //设置为第一响应
    [SN1 becomeFirstResponder];
    
    //---------------设置版本号，标题等-----------
    [TesterTitle setStringValue:[NSString stringWithFormat:@"%@__%@",param.ui_title,param.dut_type]];           //设置title
    //--------------------------
    [FlowMsg setHidden:YES];                      //隐藏掉路程提示窗口
    //--------------------------
    [TesterVersion setStringValue:param.tester_version];   //设置version
    //--------------------------
    [Station setStringValue:param.station];   //设置station
    //--------------------------
    [StationID setStringValue:param.stationID];   //设置stationID
    //--------------------------
    [FixtureID setStringValue:param.fixtureID];   //设置fixtureID
    //--------------------------
    [LineNo setStringValue:param.lineNo];   //设置lineNO
    //--------------------------
    [ctestcontext->m_dicConfiguration setObject:param.csv_path forKey:kContextCsvPath];  //把csv路径存到字典里，在perferem类的初始化里需要用到
    [ctestcontext->m_dicConfiguration setObject:param.txt_path forKey:kContextTxtPath];  //把txt路径存到字典里，在perferem类的初始化里可能需要用到
    //--------------------------
    item  = [plist PlistRead:plist_path Key:param.dut_type];     //加载对应产品的测试项
    //--------------------------
    table = [[Table alloc]init:TABLE1 DisplayData:item];    //根据测试项初始化表格
    //--------------------------
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    //----------初始化界面信息----------------
    [self initUiMsg];
    
    
    //humitureCollect=YES;
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
    
    [fixtureSerial Close];
    [humitureSerial Close];
    [keithleySerial Close];
    [agilent3458A CloseDevice];
    
}


-(void)initUiMsg
{
    //--------------------------
    index=4;
    pause=0;
    row_index=0;
    time=0;
    ct_cnt=0;
    item_index=0;
    
    //--------------------------BOOl变量初始化
    humitureCollect=false;
    isTouch=true;//治具还未下压
    
    
    //--------pass和fail数量信息统计--------
    testpasscount = 0;
    testfailcount = 0;
    testtotalcount = 0;
    testpassrate = 0;
    testfailrate = 0;
    //------------初始化界面的一些信息--------------
    [SN1 setStringValue:@""];                      //清空条码SN1
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
    [ResultBackGroundTF setBackgroundColor:[NSColor blueColor]];
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
    //根据所选的脚本，进行切换，以及本地plist文件的更改和重新读取。
    if (0 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test1Name = @"Sensor Board";
        [self ReloadScript:Test1Name];
        [param ParamWrite:param_path Content:Test1Name Key:@"dut_type"];
            }
    else if (1 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test2Name = @"Crown Flex";
        [self ReloadScript:Test2Name];
        [param ParamWrite:param_path Content:Test2Name Key:@"dut_type"];
    }
    else if (2 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test3Name = @"Sensor Flex Sub";
        [self ReloadScript:Test3Name];
        [param ParamWrite:param_path Content:Test3Name Key:@"dut_type"];
    }
    else if (3 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test4Name = @"Crown Rotation Sub";
        [self ReloadScript:Test4Name];
        [param ParamWrite:param_path Content:Test4Name Key:@"dut_type"];
    }
    else if (4 == [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue])
    {
        NSString *Test5Name = @"Test5";
        [self ReloadScript:Test5Name];
        [param ParamWrite:param_path Content:Test5Name Key:@"dut_type"];
    }
    NSString *csvpathfromdic = [ctestcontext->m_dicConfiguration valueForKey:kContextCsvPath];
    if (csvpathfromdic.length != 0)
    {
        [param ParamWrite:param_path Content:csvpathfromdic Key:@"csv_path"];
    }
    [param ParamRead:param_path];
    [TesterTitle setStringValue:[NSString stringWithFormat:@"%@__%@",param.ui_title,param.dut_type]];           //设置title
        
    });        
}
//================================================
+(id)GetObject
{
    return self;
}
//================================================
-(void)Action
{
    @autoreleasepool {
        
        //隐藏菜单
        [NSMenu setMenuBarVisible:NO];
        while([[NSThread currentThread] isCancelled] == NO)
        {
#pragma mark index=0 打开治具，串口通信            
            //***********************初始化治具
            if (index == 0) {
                
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:0,初始化治具"]];
                
                BOOL isCollect=[fixtureSerial Open:param.fixture_uart_port_name BaudRate:BAUD_115200 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                if (isCollect)
                {
                    NSLog(@"治具串口已经连接");
                    index = 1;
                }
                else
                {
                    NSLog(@"治具串口还未连接");
                    sleep(0.5);
                }

                
            }
#pragma mark index=1  打开安捷伦万用表---GPIB通信
            //------------------------------------------------------------
            //index=1
            //------------------------------------------------------------
            if (index==1)
            {
                //测试代码
                BOOL agilent3458A_isOpen = [agilent3458A FindAndOpen:nil];
                agilent3458A_isOpen = YES;
                
                if (agilent3458A_isOpen)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=1,安捷伦已经连接"]];
                    sleep(1);
                    index = 2;
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"安捷伦连接失败!"]];
                    
                    sleep(1);
                    NSLog(@"安捷伦连接失败!");
                }
            }
#pragma mark index=2 初始化温度传感器
            //------------------------------------------------------------
            //index=2
            //------------------------------------------------------------
            if(index==2)
            {
                BOOL isCollect=[humitureSerial Open:param.humiture_uart_port_name BaudRate:BAUD_9600 DataBit:DATA_BITS_8 StopBit:StopBitsOne Parity:PARITY_NONE FlowControl:FLOW_CONTROL_NONE];
                
                //测试代码
                isCollect = YES;
                
                if (isCollect)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=2,温湿度串口已经连接(OK)"]];
                    NSLog(@"温湿度串口已经连接");
                    humitureCollect=YES;
//                    [self HumitureStartTimer:2];
                    index = 3;
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=2,温湿度串口还未连接(NG)"]];
                    
                    NSLog(@"温湿度串口还未连接");
                }
            }
            
#pragma mark index=3 初始化波形发生器
            //------------------------------------------------------------
            //index=3
            //------------------------------------------------------------
            if(index==3)
            {
                //测试代码
                param.isWaveNeed = YES;
                
                if (param.isWaveNeed)  //有些工站需要，有些不需要
                {
                    BOOL agilent33210A_isFind = [agilent33210A Find:nil andCommunicateType:Agilent33210A_USB_Type];
                    BOOL agilent33210A_isOpen =[agilent33210A OpenDevice: nil andCommunicateType:Agilent33210A_USB_Type];
                    
                    //测试代码
                    agilent33210A_isFind = YES;
                    agilent33210A_isOpen = YES;
                    
                    if (agilent33210A_isFind && agilent33210A_isOpen)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=3,波形发生器已连接"]];
                        sleep(1);
                        index = 4;
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=3,波形发生器连接失败!"]];
                        sleep(1);
                        NSLog(@"波形发生器连接失败!");
                    }
                }
                else
                {
                    index = 4;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=3,波形发生器已连接"]];
                    sleep(0.5);
                }
            }
#pragma mark index=4 确保产品接触完整的指令
            //------------------------------------------------------------
            //index=4
            //------------------------------------------------------------
            if (index==4)
            {
                while (isTouch)
                {
                    isTouch=false;//下压成功
                    [fixtureSerial WriteLine:@"Reset"];
                    sleep(0.5);
                    
                    if ([[[fixtureSerial ReadExisting] uppercaseString ]containsString:@"OK"])
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=4,复位成功!"]];
                        NSLog(@"复位成功!");
                        break;
                    }
                }
                sleep(0.5);
                if(![IndexMsg.stringValue containsString:@"请按双启按钮"])
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"index=4,请按双启按钮!"]];
//                    ***********TestCode***********************//
                    index=5;
//                    ********************************************//
                }
                
                //返回Teststart,可以开始检测SN
                if ([[fixtureSerial ReadExisting] isEqualToString:@"TestStart"])
                {
                    index=5;
                }
            }
     
#pragma mark index=5  输入产品sn
            //------------------------------------------------------------
            //index=5
            //------------------------------------------------------------
            if (index == 5){//等待输入SN，程序开始运行
                
                sleep(1);
                int SFCState=[[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
              
                int ifscanSN = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckScanBarcode] intValue];
                
                if (ifscanSN == 1)
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([[SN1 stringValue] length] != 17)
                        {
                            if (![[IndexMsg stringValue]isEqualToString:@"Index:5,请输入17位条码"])
                            {
                                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:5,请输入17位条码"]];
                                NSLog(@"请输入17位条码");
                            }
                        }
                        else
                        {
                            dutsn = [SN1 stringValue];
                            [TestStep Instance].strSN=dutsn;//赋值
                            if (SFCState==1) {//上传SFC,检验SN的产品是否已经过站
                                if ([[TestStep Instance]StepSFC_CheckUploadSN:SFCState]) {
                                    [SN1 setStringValue:@""];
                                    [FlowMsg setHidden:NO];
                                    [FlowMsg setStringValue:@"已经过站!"];
                                    NSLog(@"已经过站!");
                                    index=4;
                                    isTouch=YES;
                                }
                                else
                                {
                                    [FlowMsg setHidden:YES];
                                    index = 6;
                                    
                                }
                                
                            }
                            else
                            {
                                [FlowMsg setHidden:YES];
                                index=6;
                                
                            }
                            
                            
                        }
                    
                    });
                    
                    [NSThread sleepForTimeInterval:0.1];
                }
                else
                {
                    dutsn = @"No Scan SN!!!";
                    index=6;
                }
            }
#pragma mark index=6  开始测试后，锁住编辑框，禁止编辑
            //------------------------------------------------------------
            //index=6
            //------------------------------------------------------------
            if(index == 6)
            {
                //**********************************************
                [self HumitureStartTimer:2];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:6,开始测试"]];
                //NSLog(@"=============================index is 0\r\n");
                dispatch_async(dispatch_get_main_queue(), ^{

                        //清空表格
                        [table ClearTable];
                        //设置状态
                        [TestStatus setStringValue:@"Run"];
                        [TestStatus setBackgroundColor:[NSColor blueColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor blueColor]];

                        //清空条码并锁住条码编辑框
                        [SN1Lable setStringValue:[SN1 stringValue]];
                        [SN1 setStringValue:@""];
                        [SB1 setStringValue:@""];
                        SN1.editable = NO;
                        SB1.editable = NO;
                        //清空log显示
                        NSRange range;
                        range = NSMakeRange(0, [[LOGVIEW1 string] length]);
                        [LOGVIEW1 replaceCharactersInRange:range withString:@""];

                });
                    [NSThread sleepForTimeInterval:1];
                    //记录pdca的测试时间以及启动测试的时间
                    [pdca PDCA_GetStartTime];
                    start_time = [timedate GetSystemTimeSeconds];
                    item_index = 0;
                    row_index = 0;
                    ct_cnt = 0;
                    index = 7;
                    //先停止定时器，防止重复调用[self StartTimer:0.1];方法出现错误
                    [self StopTimer];
                    //开启定时器，0.1秒一次
                    [self StartTimer:0.1];
            }
#pragma mark index=7  开始产品测试
            //------------------------------------------------------------
            //index=7
            //------------------------------------------------------------
            
            if(index == 7)
            {
                sleep(1);
               // NSLog(@"=============================index is 1\r\n");
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:7,开始运行脚本"]];
                Item *testitem = item[item_index];
                if (testitem.isNeedTest == YES) //如果测试项需要测试
                {
                    [self TestItem:testitem];
                    if(testitem.isNeedShow) //如果测试项需要显示就更新测试项显示结果
                    {
                        [table SelectRow:row_index];
                        [table flushTableRow:testitem RowIndex:row_index];
                        row_index = row_index+1;
                    }
                }
                item_index = item_index+1;
                if (item_index > ([item count]-1))
                {
                    index = 8;
                }
            }
#pragma mark index=8  脚本执行完成，解锁编辑窗口并清空
            //------------------------------------------------------------
            //index=8
            //------------------------------------------------------------
            if (index == 8)
            {
                sleep(1);
                dispatch_async(dispatch_get_main_queue(), ^{
                    //解锁编辑框
                    SN1.editable = YES;
                    SB1.editable = YES;
                
                    BOOL pf = YES;
                    
                    for (int i=0; i<[item count]; i++)
                    {
                        Item *testitem = item[i];
                        //需要测试
                        if (testitem.isNeedTest)
                        {
                            if ((testitem.isNeedShow))
                            {
                                if ([testitem.testResult isEqualToString:@"FAIL"])
                                {
                                    pf = NO;
                                }
                            }
                        }
                    }
                    
                    if (pf == YES)
                    {
                        [TestStatus setBackgroundColor:[NSColor greenColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor greenColor]];
                        [TestStatus setStringValue:@"PASS"];
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
                    }
                    else
                    {
                        [TestStatus setBackgroundColor:[NSColor redColor]];
                        [ResultBackGroundTF setBackgroundColor:[NSColor redColor]];
                        [TestStatus setStringValue:@"FAIL"];
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
                    }
                    
                });
                //记录PDCA结束时间;记录测试结束时间
                [pdca PDCA_GetEndTime];
                end_time = [timedate GetSystemTimeSeconds];
                //停止定时器
                [self StopTimer];
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:8,脚本执行完成"]];
                //---------------------
                index = 9;
            }
#pragma mark index=9  上传PDCA，生成本地CSV数据
            //------------------------------------------------------------
            //index=9
            //------------------------------------------------------------
            if (index == 9)
            {
                sleep(1);
                 [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShowErrorTipOnUI object:[NSString stringWithFormat:@"Index:8,上传PDCA,生成CSV"]];
                
                int SFCState=[[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue];
                
                int PdcaState = [[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA] intValue];
                
                if(PdcaState==1)//上传PDCA
                {
                   [self UploadPDCA];
                 
                }
                if(SFCState==1)//上传PDCA
                {
                    
                    if ( ![[TestStep Instance]StepSFC_CheckUploadResult:SFCState=0?NO:YES andIsTestPass: [TestStatus.stringValue isEqualToString:@"FAIL"]?NO:YES  andFailMessage:nil]) {
                        
                        [self UpdateLableStatus:@"SFC上传失败" andColor:[NSColor redColor]];
                       
                        
                    }
                }
                
                if (csv != nil)
                {
                    NSString *path = param.csv_path;
                    [folder Folder_Creat:path];
                    path = [path stringByAppendingString:[NSString stringWithFormat:@"/%@/",param.dut_type]];
                    [folder Folder_Creat:path];
                    NSString *timeday = [timedate GetSystemTimeDay];
                    path = [path stringByAppendingString:timeday];
                    path = [path stringByAppendingString:[NSString stringWithFormat:@"%@",param.dut_type]];
                    path = [path stringByAppendingString:@".csv"];
                    BOOL need_title = [csv CSV_Open:path];
                    [self SaveCSV:need_title];
                }
                
                if (csv!=nil)
                {
                    NSString *humitureCSV_path = param.txt_path;
                    [folder Folder_Creat:humitureCSV_path];
                    NSString *timeday = [timedate GetSystemTimeDay];
                    humitureCSV_path = [humitureCSV_path stringByAppendingString:timeday];
                    humitureCSV_path = [humitureCSV_path stringByAppendingString:@".csv"];
                    BOOL need_title = [csv CSV_Open:humitureCSV_path];
                    [self SaveHumitureCSV:(BOOL)need_title];
                }
                
                
                
                if (txt != nil)
                {
                    NSString *txt_path = param.txt_path;
                    [folder Folder_Creat:txt_path];
                    NSString *timedayfortxt = [timedate GetSystemTimeDay];
                    txt_path = [txt_path stringByAppendingString:timedayfortxt];
                    txt_path = [txt_path stringByAppendingString:@".txt"];
                    [txt TXT_Open:txt_path];
                    [txt TXT_Write:[NSString stringWithFormat:@"%@\n",LOGVIEW1.string]];
                }
                
                sleep(1);
                index = 4;
                isTouch=true;
            }
            if (index == 9999)
            {
                [NSThread sleepForTimeInterval:0.2];
            }
            [NSThread sleepForTimeInterval:0.01];
        }
    }
}


//================================================
//上传pdca
//================================================
-(void)UploadPDCA
{
    BOOL PF = YES;    //所有测试项是否pass
    
    [pdca PDCA_Init:dutsn SW_name:param.sw_name SW_ver:param.sw_ver];   //上传sn，sw_name,sw_ver
    
    [pdca PDCA_AddAttribute:sbuild FixtureID:param.fixture_id];         //上传s_build，fixture_id
    
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

    line = [NSString stringWithFormat:@"%@, %@, %@, %@, %@, %@,",dutsn, param.sw_name, param.sw_ver, param.fixture_id, start_time, end_time];
    
    
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
    
    
//    if (humitureCollect) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            NSString * string=[humitureSerial ReadExisting];
//            
//            if (string.length>0) {
//                [HumitureTF setStringValue:string];
//                humitString=string;
//            }
//            else
//            {
//                [HumitureTF setStringValue:humitString];
//            }
//            
//            
//        });
    
//    }

}

//================================================
// 开始刷新温度定时器
//================================================
-(void)HumitureStartTimer:(float)seconds
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //定义一个NSTimer
        humTimer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                 target:self
                                               selector:@selector(TimerUpdateWindow)
                                               userInfo:nil
                                                repeats:YES
                 ];
        
    });
    
}
//================================================
// 停止温度定时器
//================================================
-(void)HumitureStopTimer
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(humTimer != nil){
            [humTimer invalidate];// 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
        }
    });
}

//更新温度窗体
-(void)TimerUpdateWindow
{
    @autoreleasepool
    {

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *starttimeH = [timedate GetSystemTimeSeconds];
            //执行耗时操作
            [humitureSerial WriteLine:@"READ"];
            sleep(2);
            NSString * string=[humitureSerial ReadExisting];

            //测试代码
            string = @"45℃/23";
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                if (string.length>0)
//                {
//                    if (string.length>10)
//                    {
//                        [HumitureTF setStringValue:[string substringToIndex:11]];
//                        humitString=[string substringToIndex:11];
//                    }
//                    else
//                    {
//                        [HumitureTF setStringValue:string];
//                        humitString=string;
//                    }
//                }
//                
//                else
//                {
//                    [HumitureTF setStringValue:humitString];
//                    
//                }
                if (only_test)
                {
                    [HumitureTF setStringValue:@"++++++++"];
                    only_test = NO;
                }
                else
                {
                    [HumitureTF setStringValue:@"-------"];
                    only_test = YES;
                }
                NSString *endtimeH = [timedate GetSystemTimeSeconds];
                [humitDataArray addObject:dutsn];
                [humitDataArray addObject:starttimeH];
                [humitDataArray addObject:endtimeH];
                [humitDataArray addObject:HumitureTF.stringValue];
                
            });
            
        });


    }
}



#pragma mark=================测试项指令解析

-(BOOL)TestItem:(Item*)testitem
{
    BOOL ispass=NO;
    //--------------------
    //TestOne
    //--------------------
    for (int i=0; i<[testitem.testAllCommand count]; i++)
    {
        //治具===================Fixture
        //波形发生器==============OscillDevice
        //安捷伦万用表============Aglient
        //延迟时间================SW
        NSString     * agilentReadString;
        NSDictionary * dic=[testitem.testAllCommand objectAtIndex:i];
        NSString * SonTestDevice=dic[@"TestDevice"];
        NSString * SonTestCommand=dic[@"TestCommand"];
        int delayTime=[dic[@"TestDelayTime"] intValue]/1000;
        
        //**************************治具=Fixture
        if ([SonTestDevice isEqualToString:@"Fixture"]) {
            
            NSLog(@"治具发送指令%@========%@",SonTestDevice,SonTestCommand);
            
            [fixtureSerial WriteLine:SonTestCommand];
            sleep(0.2);
            
            NSString  * readString;
            int indexTime=0;
            
            while (YES) {
                
                readString=[fixtureSerial ReadExisting];
                
                if ([readString containsString:@"OK"]||indexTime==testitem.testRetryTimes)
                {
                    break;
                }
                indexTime++;
            }
        }
        //**************************波形发生器=WaveDevice
        else if ([SonTestDevice isEqualToString:@"WaveDevice"])
        {
            
            if ([SonTestCommand isEqualToString:@"MODE_Sine"])
            {
                [agilent33210A SetMessureMode:MODE_Sine andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            else if([SonTestCommand isEqualToString:@"MODE_Square"])
            {
                [agilent33210A SetMessureMode:MODE_Square andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else if([SonTestCommand isEqualToString:@"MODE_Ramp"])
            {
                [agilent33210A SetMessureMode:MODE_Ramp andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else if([SonTestCommand isEqualToString:@"MODE_Pulse"])
            {
                [agilent33210A SetMessureMode:MODE_Pulse andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else if([SonTestCommand isEqualToString:@"MODE_Noise"])
            {
                [agilent33210A SetMessureMode:MODE_Noise andCommunicateType:Agilent33210A_USB_Type andFREQuency:param.waveFrequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else//其它情况
            {
                NSLog(@"波形发生器其它情况");
            }
            
            NSLog(@"%@*************示波器发送指令**************%@",SonTestDevice,SonTestCommand);
            
        }
         //**************************万用表==Agilent或者Keithley
        else if ([SonTestDevice isEqualToString:@"Agilent"]||[SonTestDevice isEqualToString:@"Keithley"])
        {
    
            //万用表发送指令
            if ([SonTestCommand isEqualToString:@"DC Volt"]) {//直流电压测试
                //[agilent SetMessureMode:MODE_VOLT_DC andCommunicateType:MODE_LAN_Type];
                //[keithleySerial SetMessureMode:K_MODE_VOLT_DC];
                [agilent3458A SetMessureMode:Agilent3458A_VOLT_DC];
                NSLog(@"设置直流电压模式");
            }
            else if([SonTestCommand isEqualToString:@"AC Volt"])
            {
                //[agilent SetMessureMode:MODE_VOLT_AC andCommunicateType:MODE_LAN_Type];
                //[keithleySerial SetMessureMode:K_MODE_VOLT_AC];
                [agilent3458A SetMessureMode:Agilent3458A_VOLT_AC];
                NSLog(@"设置交流电压模式");
            }
            else if ([SonTestCommand isEqualToString:@"DC Current"])
            {
               [agilent3458A SetMessureMode:Agilent3458A_CURR_DC];
                NSLog(@"设置直流电流模式");
                
            }
            else if ([SonTestCommand isEqualToString:@"AC Current"])
            {
                
               [agilent3458A SetMessureMode:Agilent3458A_CURR_AC];
                NSLog(@"设置交流电流模式");
                
            }
            else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
            {
                [agilent3458A SetMessureMode:Agilent3458A_RES_2W];
            
                NSLog(@"设置自动电阻模式");
                
                
            }
            else//其它的值
            {
                //5次电压递增测试
                if ([testitem.testDevice isEqualToString:@"SF-5a"]) {//设备
                    
                    int indexTime=0;
                    
                    while (YES) {
                        
                        [agilent3458A WriteLine:@"END"];
                        
                        agilentReadString=[agilent3458A ReadData:16];
                        
                        //大于1，直接跳出，并发送reset指令
                        if (agilentReadString.length>0&&[agilentReadString floatValue]>=1)
                        {
                            [fixtureSerial WriteLine:@"Reset"];
                            break;
                        }
                        if ([agilentReadString floatValue]<1)//读取3次，3次后等待15秒再发送
                        {
                            indexTime++;
                            
                            if (indexTime==testitem.testRetryTimes-1) {
                                
                                sleep(13.5);
                                
                                [agilent3458A WriteLine:@"END"];
                                agilentReadString=[agilent3458A ReadData:16];
                                
                                break;
                                
                            }
                        
                        
                        }

                    }
                    
                }
                //其它正常读取情况
                else
                {
                    [agilent3458A WriteLine:@"END"];
                     agilentReadString=[agilent3458A ReadData:16];

                
                }
            
                float num=[agilentReadString floatValue];
                
                if ([SonTestCommand containsString:@"Read"]) {
                    
                    if ([testitem.testValueUnit isEqualToString:@"GΩ"]) {//GΩ的情况计算
                        
                         testitem.testValue = [NSString stringWithFormat:@"%.3f", (((0.8 - num)/num)*10)/1000];
                        
                    }
                    else if ([testitem.testValueUnit isEqualToString:@"MΩ"])//MΩ的情况计算
                    {
                        if ([testitem.testName isEqualToString:@"Sensor_Flex SF-1b"]||[testitem.testName isEqualToString:@"Crown Rotation SF-1b"]) {
                            
                            testitem.testValue = [NSString stringWithFormat:@"%.3f", ((1.41421*0.8 - num)/num)*5];
                                
                        }
                        else
                        {
                            testitem.testValue = [NSString stringWithFormat:@"%.3f", ((1.41421*0.8 - num)/num)*10];
                        
                        }
                    
                    
                    }
                    else if ([testitem.testValueUnit isEqualToString:@"kΩ"]&&[SonTestCommand containsString:@"Read"])//KΩ的情况计算
                    {
                        num=num/(10E+02);
                        testitem.testValue = [NSString stringWithFormat:@"%.3f",num];
                        
                    }
                    else if ([testitem.testValueUnit containsString:@"uA"]&&[SonTestCommand containsString:@"Read"])
                    {
                        testitem.testValue = [NSString stringWithFormat:@"%.3f",num*1000000];
                    
                    }
                    else
                    {
                        
                        testitem.testValue = [NSString stringWithFormat:@"%.3f",num];
                        
                    }

                    if ([testitem.testUpperLimit isEqualToString:@"∞"]&&[testitem.testValue floatValue]>=[testitem.testLowerLimit floatValue]) {
                        
                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
                        testitem.testResult = @"PASS";
                        testitem.testMessage= @"";
                        testitem.isPdcaValue= YES;
                        ispass = YES;

                    }

                    else if (([testitem.testValue floatValue]>=[testitem.testLowerLimit floatValue]&&[testitem.testValue floatValue]<=[testitem.testUpperLimit floatValue]))
                    {
                        
                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
                        testitem.testResult = @"PASS";
                        testitem.testMessage= @"";
                        testitem.isPdcaValue= YES;
                        ispass = YES;
                        
                    }
                    else
                    {
                        testitem.testValue  = [NSString stringWithFormat:@"%@",testitem.testValue];
                        testitem.testResult = @"FAIL";
                        testitem.testMessage= @"";
                        testitem.isPdcaValue= YES;
                        ispass = NO;
                    }
                }
            }
            
            }
        else if([SonTestDevice isEqualToString:@"SW"])
        {
            //延迟时间
             NSLog(@"延迟时间**************%@",SonTestDevice);
             sleep(delayTime);
        }
        else
        {
            NSLog(@"其它设备模式");
        }
    }
    
    return ispass;
}
//================================================
- (IBAction)SPK:(id)sender {
    
    pause = index;
    index = 20000;
    
}
//================================================

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
            [self HumitureStopTimer];
            item_index = 0;
            row_index = 0;
            ct_cnt = 0;
            index = 3;
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
            [self HumitureStopTimer];
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






@end
//================================================