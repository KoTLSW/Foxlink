//
//  Instrument.cpp
//  Instrument
//
//  Created by Liang on 15-1-8.
//  Copyright (c) 2015年 Liang. All rights reserved.
//

#include "Instrument.h"
#import "Serial.h"
#import "Lan.h"
#import "InstrumentWinDelegate.h"

void InstrumentLog(const char* msg);

extern InstrumentWinDelegate* InstrumentWinDelegateObj;


CInstrument::CInstrument()
{
    m_DicInstruments = [[NSMutableDictionary alloc] init];
}

CInstrument::~CInstrument()
{
    if (m_DicInstruments) {
        [m_DicInstruments release];
        m_DicInstruments = nil;
    }
}
int CInstrument::Create(char* name, eInstrInterfaceType type, char* szSetting)//"resource_name;setting"
{
    for (NSString *key in m_DicInstruments)
    {
        if ([key isEqualToString:[NSString stringWithUTF8String:name]]) {
            return (int)[m_DicInstruments count];
        }
    }
    /*
     #define VI_ASRL_PAR_NONE            (0)
     #define VI_ASRL_PAR_ODD             (1)
     #define VI_ASRL_PAR_EVEN            (2)
     #define VI_ASRL_PAR_MARK            (3)
     #define VI_ASRL_PAR_SPACE           (4)
     
     #define VI_ASRL_STOP_ONE            (10)
     #define VI_ASRL_STOP_ONE5           (15)
     #define VI_ASRL_STOP_TWO            (20)
     */
    if (type == eIITSerial)
    {
        NSString* strInstrName = [NSString stringWithUTF8String:name];
        NSString* strSetting = [NSString stringWithUTF8String:szSetting];
        if(strInstrName && strSetting)
        {
            NSArray* arrConfig = [strSetting componentsSeparatedByString:@";"];
            if ([arrConfig count] != 2) {
                NSLog(@"Incorrect args for creating instrument.");
                return (int)[m_DicInstruments count];
            }
            
            //format:  "rate,bits,parity,stop"
            NSArray* arrSetting = [arrConfig[1] componentsSeparatedByString:@","];
            if ([arrSetting count] == 4){
                int baud_rate   = [arrSetting[0] intValue];
                int bits        = [arrSetting[1] intValue];
                int parity      = [arrSetting[2] intValue];
                int stop        = [arrSetting[3] intValue];
                Serial* aSerial = [[Serial alloc] initWithInstr:(char*)[arrConfig[0] UTF8String] rate:baud_rate bits:bits parity:parity stop:stop];
                if (aSerial) {
                    NSString* strMsg = [NSString stringWithFormat:@"Successfully created: %@, resource name = %@, type = %d", strInstrName, arrConfig[0], type];
                    InstrumentLog([strMsg UTF8String]);
                    [m_DicInstruments setObject:aSerial forKey:strInstrName];
                    [aSerial release];
                    NSLog(@"Instrument server created: %@, resource name = %@", strInstrName, arrConfig[0]);
                }
                else{
                    NSLog(@"Failed to create instrument %@.",strInstrName);
                }
            }else{
                NSLog(@"Incorrect args for creating instrument.");
            }
        }
        else{
            NSLog(@"Incorrect args for creating instrument.");
        }
    }
    else if (type == eIITGpib)
    {
        
    }
    else if (type == eIITLan)
    {
        NSString* strInstrName = [NSString stringWithUTF8String:name];
        NSString* strSetting = [NSString stringWithUTF8String:szSetting];
        if(strInstrName && strSetting)
        {
            NSArray* arrConfig = [strSetting componentsSeparatedByString:@","];
            if ([arrConfig count] != 2) {
                NSLog(@"Incorrect args for creating instrument.");
                return (int)[m_DicInstruments count];
            }
            
            //format:  "rate,bits,parity,stop"
            NSArray* ipConfig = [[[arrConfig[0] componentsSeparatedByString:@"::"] objectAtIndex:1] componentsSeparatedByString:@"."];

//            if ([ipConfig count] == 4){
                strSetting = arrConfig[0];
                NSLog(@"LAN Source Name: %@",strSetting);
//                Lan *alan = [[Lan alloc] initWithInstr:(char*)[strSetting UTF8String]];
                Lan *alan = [[Lan alloc] initWithInstr:(char*)[[NSString stringWithFormat:@"169.254.4.10"]UTF8String]];
                if (alan) {
                    NSString* strMsg = [NSString stringWithFormat:@"Successfully created: %@, type = %d", strInstrName, type];
                    InstrumentLog([strMsg UTF8String]);
                    [m_DicInstruments setObject:alan forKey:strInstrName];
                    [alan release];
                    NSLog(@"Instrument server created: %@!\r\n", strInstrName);
                }
                else{
                    NSLog(@"Failed to create instrument %@.",strInstrName);
                }
//            }else{
//                NSLog(@"Incorrect args for creating instrument.");
//            }
        }
        else{
            NSLog(@"Incorrect args for creating instrument.");
        }

        
    }
    else if (type == eIITUsb)
    {
        
    }
    else if (type == eIITNa)
    {
        NSString* strInstrName = [NSString stringWithUTF8String:name];
        NSString* strSetting = [NSString stringWithUTF8String:szSetting];
        if(strInstrName && strSetting)
        {
            NSString* strDummyInstrument = [[NSString alloc] initWithString:@"This is a dummy instrument for debug."];
            [m_DicInstruments setObject:strDummyInstrument forKey:strInstrName];
            [strDummyInstrument release];
            NSString* strMsg = [NSString stringWithFormat:@"Successfully created: %@, type = %d(NA).", strInstrName, type];
            InstrumentLog([strMsg UTF8String]);
        }
        else{
            NSLog(@"Incorrect args for creating instrument.");
        }

    }
    return (int)[m_DicInstruments count];
}
void CInstrument::SendCmd(char*szDeviceName, char*cmd)
{
    if (szDeviceName==NULL || cmd==NULL) {
        return;
    }
    id aInstrument = nil;
    NSArray* arrAllkeys = [m_DicInstruments allKeys];
    for (int i=0; i<[arrAllkeys count]; i++) {
        if ([[NSString stringWithUTF8String: szDeviceName] isEqualToString:[arrAllkeys objectAtIndex:i]]) {
            aInstrument = [m_DicInstruments objectForKey:[arrAllkeys objectAtIndex:i]];
            break;
        }
    }
    if (aInstrument) {
        if([aInstrument respondsToSelector:@selector(send:)]){
            [aInstrument send:cmd];
            NSString* strMsg = [NSString stringWithFormat:@"Info: Instrument %@ SEND: %s", [NSString stringWithUTF8String: szDeviceName], cmd];
            InstrumentLog([strMsg UTF8String]);
        }
        else
        {
            NSLog(@"Warning: Instrument %@ does not reponse send: selector.", [NSString stringWithUTF8String: szDeviceName]);
            NSString* strMsg = [NSString stringWithFormat:@"Warning: Instrument %@ is a type of NA.", [NSString stringWithUTF8String: szDeviceName]];
            InstrumentLog([strMsg UTF8String]);
        }
    }
    usleep(10*1000);
}
char* CInstrument::SendReceive(char*szDeviceName, char* cmd, int timeout, char detect)//unit: ms
{
    if (szDeviceName == NULL) {
        return NULL;
    }
    if (cmd) {
        SendCmd(szDeviceName, cmd);
    }
    id aInstrument = nil;
    NSArray* arrAllkeys = [m_DicInstruments allKeys];
    for (int i=0; i<[arrAllkeys count]; i++) {
        if ([[NSString stringWithUTF8String: szDeviceName] isEqualToString:[arrAllkeys objectAtIndex:i]]) {
            aInstrument = [m_DicInstruments objectForKey:[arrAllkeys objectAtIndex:i]];
            break;
        }
    }
    if (aInstrument)
    {
        if (timeout) {
            if([aInstrument respondsToSelector:@selector(setTimeout:)]){
                [aInstrument setTimeout:timeout];
            }
        }
        if (detect) {
            if([aInstrument respondsToSelector:@selector(setDetectChar:)]){
                [aInstrument setDetectChar:detect];
            }
        }
        
        NSString* buf = nil;
        if([aInstrument respondsToSelector:@selector(recv)]){
            buf = [NSString stringWithFormat:@"%@", [aInstrument recv]];
            NSString* strMsg = [NSString stringWithFormat:@"Info: Instrument %@ RECV: %@", [NSString stringWithUTF8String: szDeviceName], buf];
            InstrumentLog([strMsg UTF8String]);
        }
        else
        {
            NSLog(@"Warning: Instrument %@ does not reponse recv selector.", [NSString stringWithUTF8String: szDeviceName]);
            NSString* strMsg = [NSString stringWithFormat:@"Warning: Instrument %@ is a type of NA.", [NSString stringWithUTF8String: szDeviceName]];
            InstrumentLog([strMsg UTF8String]);
            return NULL;
        }
        return (char*)[buf UTF8String];
    }
    return NULL;
}

void CInstrument::ClearBuffer(char*szDeviceName)
{
    if (szDeviceName == NULL) {
        return;
    }
    id aInstrument = nil;
    NSArray* arrAllkeys = [m_DicInstruments allKeys];
    for (int i=0; i<[arrAllkeys count]; i++) {
        if ([[NSString stringWithUTF8String: szDeviceName] isEqualToString:[arrAllkeys objectAtIndex:i]]) {
            aInstrument = [m_DicInstruments objectForKey:[arrAllkeys objectAtIndex:i]];
            break;
        }
    }
    if (aInstrument)
    {
        if([aInstrument respondsToSelector:@selector(clear)]){
            [aInstrument clear];
        }
        else
        {
            NSLog(@"Warning: Instrument %@ does not reponse clear selector.", [NSString stringWithUTF8String: szDeviceName]);
        }
    }

}

char* CInstrument::GetDeviceNames()
{
    NSString* strMsg = [NSString stringWithFormat:@"Current instrument count = %d", (int)[m_DicInstruments count]];
    InstrumentLog([strMsg UTF8String]);
    
    NSArray* arrAllkeys = [m_DicInstruments allKeys];
    if (arrAllkeys == nil) {
        return NULL;
    }
    for (NSString* key in arrAllkeys){
        if ([key length] == 0) {
            [m_DicInstruments setValue:nil forKey:key];
        }
    }
    
    NSString* strDevNames = [arrAllkeys componentsJoinedByString:@","];
    if ([strDevNames length] == 0) {
        return NULL;
    }
    
    return (char*)[strDevNames UTF8String];
}

void CInstrument::Remove(char* name)
{
    for (NSString *key in m_DicInstruments)
    {
        if ([key isEqualToString:[NSString stringWithUTF8String:name]]) {
            [m_DicInstruments setValue:nil forKey:key];
            NSString* strMsg = [NSString stringWithFormat:@"Removed insrument %s", name];
            InstrumentLog([strMsg UTF8String]);
            break;
        }
    }
}
void CInstrument::RemoveAll()
{
    NSArray* arrAllKey = [m_DicInstruments allKeys];
    for (int i=0; i<[arrAllKey count]; i++)
    {
        [m_DicInstruments setValue:nil forKey:[arrAllKey objectAtIndex:i]];
        NSString* strMsg = [NSString stringWithFormat:@"Removed insrument %s", [[arrAllKey objectAtIndex:i] UTF8String]];
        InstrumentLog([strMsg UTF8String]);
    }

}

void InstrumentLog(const char* msg)
{
    NSString * strLog = [NSString stringWithFormat:@"Instruments: %s", msg];
    [InstrumentWinDelegateObj PrintLog:strLog];
    
}