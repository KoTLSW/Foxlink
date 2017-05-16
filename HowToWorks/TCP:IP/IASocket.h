//
//  IASocket.h
//  IANetFixture
//
//  Created by Yuekie on 7/5/16.
//  Copyright (c) 2016 Louis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASocketConnection.h"

@interface IASocket : NSObject<NSStreamDelegate,IASocketConnection>
{
    uint8_t m_tmpbuffer[1024];
    IASocketConnection* m_socket;
    pthread_mutex_t m_socketmutex;
    pthread_mutex_t m_SendCmdmutex;
    NSMutableData *m_Socketinputdata;
//    SEL m_SocketCallBack;
//    id m_CallbackTarget;
//    IBOutlet id m_testview;
//    IBOutlet id m_connectbutton;
//    IBOutlet id m_statusview;
    
    id delegate;
    BOOL isControltDelegate;
    BOOL isSendDataDelegate;
    BOOL isCallbackDelegate;
}

- (void)lock;
- (void)unlock;

- (BOOL)connectSocket:(NSString*) host Port:(UInt32) port timeOut:(double)timeout;
- (BOOL)isOpen;
- (void)closeSocket;
- (void)clearBuffter;
- (int)writeString:(NSString*)str;
- (NSString*)readString:(int)timout;
- (NSString*)sendRecv:(NSString*)str :(int)timeout;

- (void)dataready:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
- (void)streamerror:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
- (void)opencompleted:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
- (void)ConnectTimeout:(NSTimer *)timer Socket:(IASocketConnection*)socket;

//- (void)SetCallback:(SEL)Callback Target:(id)object;
- (void)setDelegate:(id)newDelegate;
@end

@protocol IASocket <NSObject>
@required
- (void)SocketControlUpdate:(BOOL)State;
- (void)SendData:(NSString *)SendData;
- (void)ReceiveDataCallback:(NSString *)ReceiveData;

@end


