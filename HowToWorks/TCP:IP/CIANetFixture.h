//
//  CIANetFixture.h
//  IANetFixture
//
//  Created by Louis on 13-11-13.
//  Copyright (c) 2013年 Louis. All rights reserved.
//

#ifndef __IANetFixture__CIANetFixture__
#define __IANetFixture__CIANetFixture__

#include <iostream>
#import <Foundation/Foundation.h>


class CIANetFixture {
public:
    CIANetFixture();
    ~CIANetFixture();
public:
    void AttachSocket(id socket) ;
    bool WriteString(const char *szCMD);
    const char* ReadString(int timeout);
    const char* SendReceive(const char* str ,int timeout);

    bool isSerialPortOpen();
    int ShowMeasurePanel(char *msg) ;
    int SetDetectString(char * regex);
    int DetectString(char * regex);
    int WaitForString(int iTimeout);
    bool ClearBuffer();

    id m_mFixtureSocket;

};

#endif /* defined(__IANetFixture__CIANetFixture__) */
