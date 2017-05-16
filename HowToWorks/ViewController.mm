
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

//================================================
NSString  *param_path=@"Param";
NSString  *plist_path=@"TestItem";
NSString  *tmconfig_path=@"TmConfig";

//================================================
@interface ViewController ()
{
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
    PACSocket = new CPACSocket;
    PACSocketConnectflag = PACSocket->CreateTCPClient([[NSString stringWithFormat:@"Bill"] UTF8String], [[NSString stringWithFormat:@"127.0.0.1"] UTF8String], 5025);
    
    [[BYDSFCManager Instance]setStrSN:dutsn];//赋值
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
    //--------------------------
    index=4;
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
-(void)Action
{
    @autoreleasepool
    {
        if (PACSocketConnectflag)
        {
            NSLog(@"网络连接成功!!!!!");
            while (true)
            {
                NSString *str = [NSString stringWithUTF8String:PACSocket->TCPReadString()];
                if ([str length]>0)
                {
                    NSLog(@"%@",str);
                    //查询SFC
                    
                    
                    
                    
                    
                    
                    
                    //上传PDCA
                    
                }
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        else
        {
            NSLog(@"网络连接失败,请检查网络!!!!!!");
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