//
//  CIANetFixture.cpp
//  IANetFixture
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//
//#include "TestContext.h"
#import "Common.h"
#include "CIANetFixture.h"
#import "IASocket.h"

CIANetFixture::CIANetFixture()
{
    m_mFixtureSocket = nil;
}
CIANetFixture::~CIANetFixture()
{
    if (m_mFixtureSocket)
    {
        [m_mFixtureSocket release];
        m_mFixtureSocket = nil;
    }
}

void CIANetFixture::AttachSocket(id socket)
{
    id old = m_mFixtureSocket;
    m_mFixtureSocket = [socket retain];
    if (old)
    {
        [old release];
        old = nil;
    }
}

bool CIANetFixture::WriteString(const char *szCMD)
{
    if (szCMD)
    {
        
        return (bool)[m_mFixtureSocket writeString:[NSString stringWithUTF8String:szCMD]];
    }
    return false;
}
const char* CIANetFixture::SendReceive(const char* str ,int timeout)
{
    
#if 1
    
    if (m_mFixtureSocket && [m_mFixtureSocket isOpen])
    {
        if (strlen(str)>0) {
            NSString *nsstr=[m_mFixtureSocket sendRecv:[NSString stringWithUTF8String:str] :timeout];
            return [nsstr UTF8String];
        }
        NSLog(@"Command is NULL");
    }
    NSLog(@"Socket is disconnect");
    return NULL;
    
#else
    
    NSString* CmdTmp = [NSString stringWithCString:str encoding:NSASCIIStringEncoding];
    if ([CmdTmp isEqualToString:@"PLUNGERS_HIT_TIMES\r\n"])
    {
        [NSThread sleepForTimeInterval:1];
        return "ANSI,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,600032,51,570000,53,54,55,56,57,58,590000,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,600101\r\n";
    }
    else if ([CmdTmp isEqualToString:@"SPEED_TIME\r\n"])
    {
        [NSThread sleepForTimeInterval:1];
        return "SPEED_TIME:12000,23000,34000,45,56";
    }
    else if ([CmdTmp isEqualToString:@"KPRESS_PW\r\n"])
    {
        [NSThread sleepForTimeInterval:1];
        return "POWER_RES:1\r\n";
    }
    else if ([CmdTmp isEqualToString:@"KPRESS_COMB\r\n"])
    {
        [NSThread sleepForTimeInterval:1];
        return "COMB_RES:0,0,1,0,1,1,1,0,0,0\r\n";
    }
    else if ([CmdTmp isEqualToString:@"CARRIERSN\r\n"])
    {
        //[NSThread sleepForTimeInterval:1];
        return "CARRIERSN:CMX8ZZCARANS03050\r\n";
    }
    else if ([CmdTmp isEqualToString:@"DUTSN\r\n"])
    {
        //[NSThread sleepForTimeInterval:1];
        return "DUTSN:09876543217H3GL21\r\n";
    }
    //[NSThread sleepForTimeInterval:1];
    return "Do not match this cmd!\r\n";
#endif
}
const char* CIANetFixture::ReadString(int timeout)
{
    if (m_mFixtureSocket && [m_mFixtureSocket isOpen])
    {
        NSString* Str = [m_mFixtureSocket readString:timeout];
        if (Str)
        {
            return [Str UTF8String];
        }
    }
    
    return NULL;
}

bool CIANetFixture::ClearBuffer()
{
    if (m_mFixtureSocket)
    {
        [m_mFixtureSocket clearBuffter];
        return true;
    }
    return false;
}

//bool CIANetFixture::FixtureStart()
//{
//    IASocket* tmp = (IASocket*)m_mFixtureSocket;
//    return [tmp GetFixtureState];
//}

//bool CIANetFixture::SetCallback(SEL Callback,id object)
//{
//    if (m_mFixtureSocket)
//    {
//        [m_mFixtureSocket SetCallback:Callback Target:object];
//        return true;
//    }
//    return false;
//}

//int CIANetFixture::ShowMeasurePanel(char *msg)
//{
//
//}
//
//int CIANetFixture::SendCmd(char* szCmd, int timeout)
//{
//
//}
//
int CIANetFixture::SetDetectString(char * regex)
{
    return 0;
}
int CIANetFixture::DetectString(char * regex)
{
    return 0;
}
int CIANetFixture::WaitForString(int iTimeout)
{
    return 0;
}

bool CIANetFixture::isSerialPortOpen()
{
    if (m_mFixtureSocket == nil)
    {
        return NO;
    }
    return [m_mFixtureSocket isOpen];
}
