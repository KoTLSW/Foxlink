//
//  Instrument.h
//  Instrument
//
//  Created by Liang on 15-1-8.
//  Copyright (c) 2015年 Liang. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

typedef enum{
    eIITNa = 0,
    eIITSerial = 1,
    eIITGpib = 2,
    eIITLan = 3,
    eIITUsb = 4
    
}eInstrInterfaceType;

class CInstrument{
public:
    CInstrument();
    ~CInstrument();
public:
    
    int Create(char* name, eInstrInterfaceType type, char* szSetting);
    void SendCmd(char*szDeviceName, char* cmd);
    char* SendReceive(char*szDeviceName, char* cmd, int timeout, char detect);
    void Remove(char* name);
    void RemoveAll();
    void ClearBuffer(char*szDeviceName);
    char* GetDeviceNames();
    
protected:
    NSMutableDictionary* m_DicInstruments;
};
