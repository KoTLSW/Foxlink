


//
//  SocketDelegate.m
//  IANetFixture
//
//  Created by Yuekie on 7/5/16.
//  Copyright (c) 2016 Louis. All rights reserved.
//

#import "SocketDelegate.h"

#define SOCKET_CLILENT    @"ArmSocket"
#define LOCAL_ARM_SOCKET_IP "169.254.1.1"
#define REMOTE_ARM_SOCKET_IP "192.168.250.50"
#define LOCAL_PORT    8600
#define DEFAULT_LOCAL_PORT    9000
#define REMOTE_PORT     9600
#define PORT_BASE 0
#define VERSION_COMMAND "[123456]version(1)\r\n"

SocketDelegate* parmsocketboardWindowDelegate = nil ;

@implementation SocketDelegate
@synthesize dicConfiguration;
@synthesize strCfgFile;

- (id)init
{
    self = [super initWithWindowNibName:@"Socket"];
    
    if (self) {
        // Initialization code here.
//        m_recive_dataInput = [[NSMutableData alloc] init];

        
    }
    parmsocketboardWindowDelegate = self ;
    return self;
}
-(void)windowDidLoad
{
    [super windowDidLoad];
}
- (void)dealloc
{
    if (m_arrCmdHistory)
    {
//        [m_arrCmdHistory release];
        m_arrCmdHistory = nil;
    }
    
//    [m_recive_dataInput release];
    m_recive_dataInput = nil;
//    [super dealloc];
}


-(void)awakeFromNib
{
    [self LoadConfig:strCfgFile];
    [self TcpIpPortInitial];
    [socketLog setUsesFindBar:YES];
    [socketLog setEditable:NO];
//    [socketServerPort setStringValue:[NSString stringWithFormat:@"%d" ,m_SocketServerPort]];
//    socketConnectionName.stringValue =m_SocketServerIP;
    [txtCmd becomeFirstResponder];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(int)LoadConfig:(NSString *)strfile
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    //default parameter
    if (![fm fileExistsAtPath:strfile])
    {
        [dicConfiguration setValue:SOCKET_CLILENT forKey:KEY_SPArmSocketBoard];
        [dicConfiguration setValue:@REMOTE_ARM_SOCKET_IP forKey:KEY_SETTING_ArmSocketIp];
        [dicConfiguration setValue:[NSString stringWithFormat:@"%d",REMOTE_PORT] forKey:KEY_SETTING_ArmSocketPort];
        [dicConfiguration writeToFile:strfile atomically:YES];
    }
    else
    {
        [dicConfiguration setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:strfile]];
    }

    return 0;
}

-(int)SaveConfig:(NSString *)strfile
{
    [dicConfiguration setValue:[socketConnectionName stringValue] forKey:KEY_SPArmSocketBoard];
    [dicConfiguration setValue:[socketServerIP stringValue] forKey:KEY_SETTING_ArmSocketIp];
    [dicConfiguration setValue:[socketServerPort stringValue]  forKey:KEY_SETTING_ArmSocketPort];
    [dicConfiguration writeToFile:strfile atomically:YES];
    
    return 0;
}

-(int)TcpIpPortInitial
{
    
    [socketConnectionName setStringValue:@"Bill"];
    [socketServerIP setStringValue:@"127.0.0.1"];
    [socketServerPort setStringValue:@"5025"];
    //[statusPic SetButtonColor:NO];
    //[ConnectToPresentServer setTitle:@"Connect"];
    
    [socketClient connectSocket:[socketServerIP stringValue] Port:[socketServerPort intValue] timeOut:5];
    [socketClient setDelegate:self];
    //[socketClient SetCallback:@selector(SocketCallBack:) Target:self];
    
    
    return 0;
}

-(int)SaveLog:(NSString *)filepath index:(int)uID
{
    [[NSFileManager defaultManager] createDirectoryAtPath:[filepath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSError * err;
    BOOL b =  [[socketLog string]writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    if (!b)
    {
        NSString * strError = [NSString stringWithFormat:@"Save ArmSocketBoard uart log failed!\r\n%@",[err description]];
        NSRunAlertPanel(@"Save Log", @"%@", @"OK", nil, nil, strError);
    }
    return b;
}

-(char *)getLog:(int)uID
{
    if (uID<0 ||uID>5)
    {
        return (char*)"";
    }
    NSString *strLog = [NSString stringWithString:[socketLog string]] ;
    return (char*)strLog.UTF8String;
}

-(int)setFALog:(int)uID LogInfo:(char*)log
{
    if (uID<0 ||uID>5 || log==NULL)
    {
        return -1 ;
    }
    return 0;
}

-(int)setFALogPath:(int)uID FilePath:(char*)filepath
{
    return 0;
}
#pragma mark ACTION

#pragma mark notification


-(void)OnConfNotification:(NSNotification *)nf
{
    NSDictionary * dic = [nf userInfo];
    
    if ([[dic objectForKey:[nf name]] isEqualToString:@"0"])
    {
        [self performSelectorOnMainThread:@selector(menuDebugPanel:) withObject:self waitUntilDone:YES];
    }
}

-(void)handleTestProcess:(NSNotification *)nf
{
    //may be need swtich to UI thread
    NSDictionary * dic = [nf userInfo];
    [self performSelectorOnMainThread:@selector(TestInitial:) withObject:dic waitUntilDone:YES];
}



#pragma mark MenuAction
-(IBAction)menuDebugPanel:(id)sender
{
    [winArmSocketBoard center];
    [winArmSocketBoard makeKeyAndOrderFront:sender];
}


#pragma mark btSend
-(IBAction)btSend:(id)sender
{
    NSString * strCmd = [txtCmd stringValue];
    
    if (strCmd.length<=0)
    {
        NSRunAlertPanel(@"NO command", @"Please write down your command first!", @"OK", nil, nil);
        return;
    }
    
    if ([strCmd isEqualToString:@"help"])
    {
        NSString* Cmd = @"CARRIERSN\nDUTSN\nSPEED_TIME\nPLUNGERS_HIT_TIMES\nKPRESS_COMB\nALARM_START\nALARM_STOP\nFAIL\nPASS\n";
        [self PrintLog:[@"Command :\n" stringByAppendingString:Cmd] TextView:socketLog];
        return;
    }
    
    if ([m_arrCmdHistory indexOfObject:strCmd]==NSNotFound)
    {
        [m_arrCmdHistory addObject:strCmd];
    }
    
    if([socketClient isOpen])
    {
        NSString *cmd = [NSString stringWithFormat:@"%@\r\n",strCmd];
        [socketClient writeString:cmd];
    }
    else
    {
        NSRunAlertPanel(@"Open Serialport", @"Please open the serialport first!", @"OK", nil, nil);
    }
}



-(IBAction)btConnectToPresentServer:(id)sender
{
    [self SaveConfig:strCfgFile];
    if (![socketClient isOpen]) //close
    {
        [socketClient connectSocket:[socketServerIP stringValue] Port:[socketServerPort intValue] timeOut:5];
    }
    else
    {
        [socketClient closeSocket];
        [self SocketControlUpdate:NO];
    }
}

#pragma mark Combo Box Delegate
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [m_arrCmdHistory objectAtIndex:index];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [m_arrCmdHistory count];
}


-(void)logOut:(NSString*)msg TargetView:(NSTextView*)view
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    int length = 0;
    NSAttributedString *theString;
    NSRange theRange;
    NSString * str = [NSString stringWithFormat:@"%@ %@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[view textStorage] appendAttributedString: theString];
    length = (int)[[view textStorage] length];
    theRange = NSMakeRange(length, 0);
    [view scrollRangeToVisible:theRange];
    if(dateFormatter != nil)
    {
//        [dateFormatter release];
        dateFormatter = nil;
    }
    if (theString != nil) {
//        [theString release];
        theString = nil;
    }
    [view setNeedsDisplay:YES];
}

-(void)PrintLog:(NSString*)msg TextView: (NSTextView*)view
{
    if (!view)
    {
        NSLog(@"Invalid view interface");
        return;
    }
    [self performSelectorOnMainThread:@selector(logOut:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:msg,@"Message",view,@"TextView",nil] waitUntilDone:YES];
}

-(void)PrintLogFromOutSide:(NSString*)msg ClientName: (NSString*)name
{
    [self PrintLog:msg TextView:socketLog];
}

- (void)SocketControlUpdate:(BOOL)State
{
    if (State)
    {
        [statusPic SetButtonColor:YES];
        [ConnectToPresentServer setTitle:@"Disconnect"];
        [socketServerIP setEnabled:NO];
        [socketServerPort setEnabled:NO];
        [socketConnectionName setEnabled:NO];
        [self PrintLog:@"ArmSocket Connected To Server\r\n" TextView:socketLog];
    }
    else
    {
        [statusPic SetButtonColor:NO];
        [ConnectToPresentServer setTitle:@"Connect"];
        [socketServerIP setEnabled:YES];
        [socketServerPort setEnabled:YES];
        [socketConnectionName setEnabled:YES];
        [self PrintLog:@"ArmSocket Connected To Server Fail\r\n" TextView:socketLog];
    }
}

- (void)SendData:(NSString *)SendData
{
    NSString* Str = [NSString stringWithString:SendData];
    [self performSelectorOnMainThread:@selector(logOut:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:Str,@"Message",socketLog,@"TextView",nil] waitUntilDone:YES];
}

- (void)ReceiveDataCallback:(NSString *)ReceiveData
{
    NSString* Str = [NSString stringWithString:ReceiveData];
    [self performSelectorOnMainThread:@selector(logOut:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:Str,@"Message",socketLog,@"TextView",nil] waitUntilDone:YES];
    
}

-(void)logOut:(NSDictionary*)dic
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    NSUInteger length = 0;
    NSTextView* view = [dic objectForKey:@"TextView"];
    NSString* msg = [dic objectForKey:@"Message"];
    NSAttributedString *theString;
    NSRange theRange;
    NSString * str = [NSString stringWithFormat:@"%@ %@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[view textStorage] appendAttributedString: theString];
    length = [[view textStorage] length];
    
    if (length > 1000000)
    {
        NSLog(@"The length of log data is too big, much then 1000000 bytes, cleared at %@",str);
        [[view textStorage] replaceCharactersInRange:NSMakeRange(0, [[view textStorage] length]) withString:@"Too much data, cleared to save memory\r\n"];
    }
    
    theRange = NSMakeRange(length, 0);
    [view scrollRangeToVisible:theRange];
    if (dateFormatter) {
//        [dateFormatter release];
        dateFormatter = nil;
    }
    if (theString) {
//        [theString release];
        theString = nil;
    }
    [view setNeedsDisplay:YES];
}

-(IBAction)CommandAction:(id)sender
{
    NSButton* bt = (NSButton*)sender;
    if([socketClient isOpen])
    {
        NSString *cmd = [NSString stringWithFormat:@"%@\r\n",[bt identifier]];
        [socketClient writeString:cmd];
    }
    else
    {
        NSRunAlertPanel(@"SerialPort Error", @"Please open PLC LAN first!", @"OK", nil, nil);
    }
}

@end
