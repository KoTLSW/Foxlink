//
//  InstrumentWinDelegate.cpp
//  Instrument
//
//  Created by Liu Liang on 13-12-23.
//  Copyright (c) 2013年 Liu Liang. All rights reserved.
//

#include "InstrumentWinDelegate.h"
#import "Common.h"
#include "VISA/visa.h"
#import "Instrument.h"
//#import "RegexKitLite.h"


#define INTERFACE_NA @"NA"
#define INTERFACE_SERIAL @"Serial"
#define INTERFACE_GPIB @"GPIB"
#define INTERFACE_LAN @"LAN"
#define INTERFACE_USB @"USB"

InstrumentWinDelegate* InstrumentWinDelegateObj = nil;

CInstrument *Instrument1;

@implementation InstrumentWinDelegate

@synthesize dicConfiguration,strCfgFile ;
- (id)init
{
    self = [super initWithWindowNibName:@"InstrumentDebugPanel"];
    dicConfiguration = nil;
    
    Instrument1 = new CInstrument();
    
    if (self) {
        //key=instrument_name   value=instrument_config(format: "type/////device_name;setting")
        dicConfiguration = [[NSMutableDictionary alloc] init];
        arrCommands = [[NSMutableArray alloc] initWithObjects:@"*idn?", nil];
#if 0
        NSString * contentPath = [[NSBundle bundleForClass:[self class]]executablePath];
        contentPath = [[contentPath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent];
        self.strCfgFile = [contentPath stringByAppendingPathComponent:@"/Config/GT_Instrument_Config.plist"];
        [[NSFileManager defaultManager] createDirectoryAtPath:[self.strCfgFile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
#else
        
       
        
//        NSString * config_dir  = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
//        NSString * config_file = [config_dir stringByAppendingPathComponent:@"GT_Instrument_Config.plist"];
         NSString * config_dir = [[NSBundle mainBundle]resourcePath];
         NSString * config_file = [config_dir stringByAppendingPathComponent:@"/GT_Instrument_Config.plist"];
        [[NSFileManager defaultManager] createDirectoryAtPath:config_dir withIntermediateDirectories:YES attributes:nil error:nil];
        self.strCfgFile = config_file;
#endif
//        [[NSNotificationCenter defaultCenter] addObserver:self selector
//                                                         :@selector(handleNotification:) name
//                                                         :kNotificationAttachMenu object
//                                                         :nil];
    }
    InstrumentWinDelegateObj = self;
    return self;
}

- (void)dealloc
{
    [dicConfiguration writeToFile:strCfgFile atomically:YES];
    delete Instrument1 ;
    
    [dicConfiguration release] ;
    [arrCommands release];
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
    [super dealloc];
}

-(void)awakeFromNib
{
    [combInstrumentType addItemWithObjectValue:INTERFACE_NA];
    [combInstrumentType addItemWithObjectValue:INTERFACE_SERIAL];
    [combInstrumentType addItemWithObjectValue:INTERFACE_GPIB];
    [combInstrumentType addItemWithObjectValue:INTERFACE_LAN];
    [combInstrumentType addItemWithObjectValue:INTERFACE_USB];
    
    [combInstrumentType setStringValue:INTERFACE_SERIAL];
    
    [combInstrument removeAllItems];
    [combVisaDevice removeAllItems];
    
    [self PrintLog:@"InstrumentWinDelegate:awakeFromNib\n\n"];
    
    [self LoadConfig:strCfgFile];
}

-(int)LoadConfig:(NSString *)strfile
{
    NSFileManager * fm = [NSFileManager defaultManager];
    
    //default parameter
    if (![fm fileExistsAtPath:strfile]) {
        [self performSelectorOnMainThread:@selector(ShowWarning:) withObject:@"Warning: No instrument created!" waitUntilDone:NO];
    }
    else
    {
        [dicConfiguration setValuesForKeysWithDictionary:[NSDictionary dictionaryWithContentsOfFile:strfile]];
    }
    [self InitInstruments];
    return 0;
}

-(void)InitInstruments
{
    int count = 0;
    for (NSString* strInstrumentName in dicConfiguration){
        NSString* name = nil;
        if ([strInstrumentName length] == 0) {
            count++;
            name = [NSString stringWithFormat:@"NoName%d",count];
        }else{
            name = strInstrumentName;
        }
        if ([[dicConfiguration valueForKey:strInstrumentName] length] == 0) {
            NSString* strMsg = [NSString stringWithFormat:@"Waring: incorrect setting for create instrument %@.",strInstrumentName];
            [self performSelectorOnMainThread:@selector(ShowWarning:) withObject:strMsg waitUntilDone:NO];
            [dicConfiguration removeObjectForKey:strInstrumentName];
        }
        else{
            NSArray* arr = [[dicConfiguration valueForKey:strInstrumentName] componentsSeparatedByString:@"/////"];
            if ([arr count] == 2) {
                [self btScanInstrument:nil];
                int count2 = (int)[combInstrument numberOfItems];
                int ret = Instrument1->Create((char*)[name UTF8String], (eInstrInterfaceType)[arr[0] intValue], (char*)[arr[1] UTF8String]);
                if (ret <= count2) {
                    NSString* strMessage = [NSString stringWithFormat:@"Failed to create instrument %@.", name];
                    [self ShowWarning:strMessage];
                }
            }else{
                NSString* strMsg = [NSString stringWithFormat:@"Waring: incorrect setting for create instrument %@.",strInstrumentName];
                [self performSelectorOnMainThread:@selector(ShowWarning:) withObject:strMsg waitUntilDone:NO];
                [dicConfiguration removeObjectForKey:strInstrumentName];
            }
        }
    }
    
    [self btScanInstrument:nil];
    [self btSaveConfig:nil];
}

#pragma mark-inner function


-(IBAction)btRescanVisaDevice:(id)sender
{
    ViStatus    status;
    ViSession   defaultRM;
    ViSession   instr;
    ViChar  rsrcName[VI_FIND_BUFLEN];
    ViChar  intfDesc[VI_FIND_BUFLEN];
    ViUInt32    retCount;
    ViFindList  flist;
    
    status = viOpenDefaultRM(&defaultRM);
    if (status < VI_SUCCESS) {
        [self performSelectorOnMainThread:@selector(ShowWarning:) withObject:@"Error in opening VISA resource manager." waitUntilDone:NO];
        return;
    }
    
    [combVisaDevice removeAllItems];
    
    status = viFindRsrc (defaultRM, (char*)"?*INSTR", &flist, &retCount, rsrcName);
    int iInstrumentCount = 0;
    while (retCount--) {
        status = viOpen (defaultRM, rsrcName, VI_NULL, VI_NULL, &instr);
        NSString* strInfo = nil;
        if (status < VI_SUCCESS)
        {
            strInfo = [NSString stringWithFormat:@"Could not open %s, status = 0x%08X", rsrcName, status];
        }
        else
        {
            status = viGetAttribute (instr, VI_ATTR_INTF_INST_NAME, intfDesc);
            //ASRL1::INSTR, ASRL1  (/dev/cu.Bluetooth-Incoming-Port)
            strInfo = [NSString stringWithFormat:@"%s, %s", rsrcName, intfDesc];
            status = viClose (instr);
            
            //strInfo = [strInfo stringByMatching:@"\\((.+)\\)" capture:1];
            if (strInfo){
                [combVisaDevice addItemWithObjectValue:strInfo];
                if (!iInstrumentCount) [combVisaDevice setStringValue:strInfo];
                iInstrumentCount++;
            }
        }
        status = viFindNext (flist, rsrcName);
    }
    viClose (flist);
    viClose (defaultRM);
    return;
}

-(IBAction)btScanInstrument:(id)sender
{
    [combInstrument setStringValue:@""];
    [combInstrument removeAllItems];
    char* szDevNames = Instrument1->GetDeviceNames();
    if (szDevNames) {
        NSArray* arr = [[NSString stringWithUTF8String:szDevNames] componentsSeparatedByString:@","];
        for (int i=0; i<[arr count]; i++){
            [combInstrument addItemWithObjectValue:arr[i]];
            if (!i) [combInstrument setStringValue:arr[i]];
        }
    }
}

-(IBAction)btCreateInstrument:(id)sender
{
    NSString* name = [txtInstrumentName stringValue];
    if ([name length] == 0) return;
    
    [self btScanInstrument:nil];
    int count = (int)[combInstrument numberOfItems];
    
    eInstrInterfaceType type = eIITNa;
    
    if ([[combInstrumentType stringValue] isEqualToString:INTERFACE_SERIAL]) {
        type = eIITSerial;
        if ([[txtSetting stringValue] length] && [[combVisaDevice stringValue] length]) {
            NSString* strRscName = nil;
            NSArray* arrVisaRsc = [[combVisaDevice stringValue] componentsSeparatedByString:@","];//rsc_name,dev_name
            if ([arrVisaRsc count] == 2) {
                strRscName = arrVisaRsc[0];//rsc_name
            }
            if (strRscName == nil) {
                return;
            }
            NSString* strConfig = [NSString stringWithFormat:@"%@;%@", strRscName, [txtSetting stringValue]];
            
            int ret = Instrument1->Create((char*)[name UTF8String], type, (char*)[strConfig UTF8String]);
            if (ret <= count) {
                NSString* strMessage = [NSString stringWithFormat:@"Failed to create instrument %@.", name];
                [self ShowWarning:strMessage];
            }
            else{//success
                NSString* strConfigToSave = [NSString stringWithFormat:@"%d/////%@", type, strConfig];
                [dicConfiguration setValue:strConfigToSave forKey:name];
            }
        }
        [self btScanInstrument:nil];
        return;
    }
    else if ([[combInstrumentType stringValue] isEqualToString:INTERFACE_GPIB]) {
        type = eIITGpib;
    }
    else if ([[combInstrumentType stringValue] isEqualToString:INTERFACE_LAN]) {
        type = eIITLan;
        if ([[combVisaDevice stringValue] length]) {
            NSString* strRscName = nil;
            NSArray* arrVisaRsc = [[combVisaDevice stringValue] componentsSeparatedByString:@"::"];//rsc_name,dev_name
            if ([arrVisaRsc count] == 4) {
                strRscName = [combVisaDevice stringValue];//rsc_name
            }
            if (strRscName == nil) {
                return;
            }
            NSString* strConfig = [NSString stringWithFormat:@"%@,%@", arrVisaRsc[1],arrVisaRsc[2]];
            
            int ret = Instrument1->Create((char*)[name UTF8String], type, (char*)[strConfig UTF8String]);
            if (ret <= count) {
                NSString* strMessage = [NSString stringWithFormat:@"Failed to create instrument %@.", name];
                [self ShowWarning:strMessage];
            }
            else{//success
                NSString* strConfigToSave = [NSString stringWithFormat:@"%d/////%@", type, strConfig];
                [dicConfiguration setValue:strConfigToSave forKey:name];
            }
        }
        [self btScanInstrument:nil];
        return;

    }
    else if ([[combInstrumentType stringValue] isEqualToString:INTERFACE_USB]) {
        type = eIITUsb;
    }
    else if ([[combInstrumentType stringValue] isEqualToString:INTERFACE_NA]) {
        if ([[txtSetting stringValue] length]) {
            int ret = Instrument1->Create((char*)[name UTF8String], type, (char*)[[txtSetting stringValue] UTF8String]);
            if (ret <= count) {
                NSString* strMessage = [NSString stringWithFormat:@"Failed to create instrument %@.", name];
                [self ShowWarning:strMessage];
            }
            else{//success
                NSString* strConfig = [NSString stringWithFormat:@"%d/////%@", type, [txtSetting stringValue]];
                [dicConfiguration setValue:strConfig forKey:name];
            }
        }
        [self btScanInstrument:nil];
        return;
    }
    
    [self ShowWarning:@"Specified interface is not supported by current version."];
    return;
}

-(IBAction)btSaveConfig:(id)sender
{
    [dicConfiguration writeToFile:strCfgFile atomically:YES];
}

-(IBAction)btRemoveInstrument:(id)sender
{
    NSString* strInstrumentName = [combInstrument stringValue];
    Instrument1->Remove((char*)[strInstrumentName UTF8String]);
    [dicConfiguration setValue:nil forKey:strInstrumentName];
    [self btScanInstrument:nil];
    [self btSaveConfig:nil];
}

-(IBAction)btRemoveAllInstruments:(id)sender
{
    Instrument1->RemoveAll();
    for (NSString* key in dicConfiguration) {
        [dicConfiguration setValue:nil forKey:key];
    }
    [self btScanInstrument:nil];
    [self btSaveConfig:nil];
}

-(IBAction)btSend:(id)sender
{
    NSString* strInstrumentName = [combInstrument stringValue];
    if ([[combCmd stringValue] length] == 0) {
        [self PrintLog:@"Invalid command"];
        return;
    }
    NSString* cmdToSend = [NSString stringWithFormat:@"%@\n", [combCmd stringValue]];
    Instrument1->SendCmd((char*)[strInstrumentName UTF8String], (char*)[cmdToSend UTF8String]);
    BOOL bExsistObj = NO;
    for (NSString* cmd in arrCommands){
        if ([cmd isEqualToString:[combCmd stringValue]]) {
            bExsistObj = YES;
        }
    }
    if (bExsistObj == NO) {
        [arrCommands addObject:[combCmd stringValue]];
        [combCmd removeAllItems];
        for (NSString* cmd in arrCommands){
            [combCmd addItemWithObjectValue:cmd];
        }
    }
}

-(IBAction)btRecv:(id)sender
{
    NSString* strInstrumentName = [combInstrument stringValue];
    char charToDetect = '\n';
    int timeout = 1000;
    if ([[txtCharToDetect stringValue] length] != 0) {
        if ([[txtCharToDetect stringValue]  isEqualToString: @"\\r"]) {
            charToDetect = '\r';
        }
    }
    if ([[txtTimeout stringValue] length] != 0) {
        timeout = [[txtTimeout stringValue] intValue];
    }
    Instrument1->SendReceive((char*)[strInstrumentName UTF8String], NULL, timeout, charToDetect);
}


//#pragma mark--handle notifiction
//-(void)handleNotification:(NSNotification*)nf
//{
//    NSDictionary *userInfo = [nf userInfo] ;
//    if ([nf.name isEqualToString:kNotificationAttachMenu])
//    {
//        NSMenu * instrMenu = [userInfo objectForKey:@"menus"];
//        [instrMenu addItem:menuItem];
//    }
//    return ;
//}
//
//#pragma mark--FCT MenuItem action function
//-(IBAction)menu_ShowDebugPanel:(id)sender
//{
//    [mWinDebugPanel center];
//    [mWinDebugPanel makeKeyAndOrderFront:sender];
//}
//
//-(IBAction)menu_ShowConfigPanel:(id)sender
//{
//    [mWinConfigPanel center];
//    if ([NSApp runModalForWindow:mWinConfigPanel])    //Click On OK
//    {
//        
//    }
//}

-(void)ShowWarning:(NSString*)msg
{
    NSRunAlertPanel(@"Instrument manager warning", @"%@", @"OK", nil, nil, msg);
}

-(void)logOut:(NSString*)msg
{
    DebugMsgCounter++;
    if (DebugMsgCounter > 10000) {
        [mLog setString:@""];
        DebugMsgCounter = 0;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss.SSS : "];
    int length = 0;
    NSAttributedString *theString;
    NSRange theRange;
    
    NSString * str = [NSString stringWithFormat:@"%@ %@\r",[dateFormatter stringFromDate:[NSDate date]],msg];
    theString = [[NSAttributedString alloc] initWithString:str];
    [[mLog textStorage] appendAttributedString: theString];
    length = (int)[[mLog textStorage] length];
    theRange = NSMakeRange(length, 0);
    [mLog scrollRangeToVisible:theRange];
    [dateFormatter release];
    [theString release];
    [mLog setNeedsDisplay:YES];
}

-(void)PrintLog:(NSString*)strMsg
{
    [self performSelectorOnMainThread:@selector(logOut:) withObject:strMsg waitUntilDone:YES];
}

#pragma mark--UI Action function

@end
