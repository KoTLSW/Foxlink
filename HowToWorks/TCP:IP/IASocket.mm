//
//  IASocket.mm
//  IANetFixture
//
//  Created by Yuekie on 7/5/16.
//  Copyright (c) 2016 Louis. All rights reserved.
//

#import "IASocket.h"
#include "pthread.h"


@implementation IASocket

-(id)init
{
    self = [super init];
    if (self)
    {
        pthread_mutex_init(&m_socketmutex, NULL);
        pthread_mutex_init(&m_SendCmdmutex,NULL);
        m_Socketinputdata=[[NSMutableData alloc]init];
        m_socket = nil;
    }
    
    return self;
}

-(void)dealloc
{
//    [m_Socketinputdata release];
    [self closeSocket];
//    [super dealloc];
}

-(void)closeSocket
{
    if (m_socket)
    {
        [m_socket close];
//        [m_socket release];
        m_socket = nil;
    }
}

- (BOOL)connectSocket:(NSString*) host Port:(UInt32) port timeOut:(double)timeout
{
    if (host != nil)
    {
        [self closeSocket];
        m_socket = [[IASocketConnection alloc] initWithHost:[host UTF8String] Port:port];
        [m_socket setDelegate:self];
        [m_socket open:timeout];
        [NSThread sleepForTimeInterval:0.1];
        return [m_socket isOpen];
    }
    
    return NO;
}

- (BOOL)isOpen
{
    if (m_socket == nil)
    {
        return NO;
    }
    return [m_socket isOpen];
}

- (void)clearBuffter
{
     @synchronized(m_Socketinputdata)
    {
        [m_Socketinputdata setLength:0];
    }
}

-(void)lock
{
    pthread_mutex_lock(&m_socketmutex);
}

-(void)unlock
{
    pthread_mutex_unlock(&m_socketmutex);
}

- (int)writeString:(NSString*)str
{
    if ([self isOpen])
    {
        if (str)
        {
            NSString *str1=[NSString stringWithFormat:@"send :%@",str];
            //[self performSelectorOnMainThread:@selector(logOut:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:str1,@"Message",m_testview,@"TextView",nil] waitUntilDone:YES];
            if (isSendDataDelegate)
            {
                [delegate SendData:str1];
            }
            else
            {
                NSLog(@"SendData data,please add 'SendData' function");
            }
            return (int)[m_socket write:[str UTF8String] maxLength:[str length]];
        }
    }
    return 0;
}

-(NSString*)readString:(int)timout
{
    if ([self isOpen])
    {
        NSTimeInterval TimeOut = (NSTimeInterval)timout;
        TimeOut = TimeOut/1000;
        NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
        while (true)
        {
             @synchronized(m_Socketinputdata)
            {
                if ([m_Socketinputdata length]>0)
                {
                    NSString *str=[[NSString alloc] initWithData:m_Socketinputdata encoding:NSASCIIStringEncoding];
                    if (str && [str length]!=0)
                    {
                        NSString *str1=[NSString stringWithString:str];
//                        [str release];
                        [m_Socketinputdata setLength:0];//clear buffter
                        return str1;
                    }
//                    [str release];
                }
            }
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            if (now - start > TimeOut)
            {
                break;
            }
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
            [NSThread sleepForTimeInterval:0.01];
        }
    }
    
    return nil;
}

- (NSString*)sendRecv:(NSString*)str :(int)timeout
{
    NSString *strRet=@"";
//    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]];
    pthread_mutex_lock(&m_SendCmdmutex);
    [self clearBuffter];
    [self writeString:str];
    strRet=[self readString:timeout];
    pthread_mutex_unlock(&m_SendCmdmutex);
    return strRet;
}

-(void)ShowMsg:(NSString*)msg
{
    [self performSelectorOnMainThread:@selector(fnErrMsg:) withObject:msg waitUntilDone:NO];
}

-(void)fnErrMsg:(id)par
{
    //NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"id",par,@"msg",nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationOnTestError object:nil userInfo:dic];
}

- (void)dataready:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSInteger actuallyRead;
    NSInputStream *instream = (NSInputStream*)aStream;
    actuallyRead = [instream read:(uint8_t *)m_tmpbuffer maxLength:sizeof(m_tmpbuffer)];
    if(actuallyRead<1)
    {
        NSLog(@"read data error(data lenght=%ld)",actuallyRead);
        return;
    }
    m_tmpbuffer[actuallyRead]='\0';
    @synchronized(m_Socketinputdata)
    {
        
        [m_Socketinputdata setLength:0];
        [m_Socketinputdata appendBytes:m_tmpbuffer length:actuallyRead];
    }
    NSString * readString = [NSString stringWithFormat:@"recv :%s",(char*)m_tmpbuffer];
    if (isCallbackDelegate)
    {
        [delegate ReceiveDataCallback:readString];
    }
    else
    {
        NSLog(@"receive data,please add 'ReceiveDataCallback' function");
    }
}

- (void)streamerror:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch ([aStream streamStatus]) {
        case NSStreamStatusNotOpen:
            [self ShowMsg:@"connect PLC Command error"];
            [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
            break;
        case NSStreamStatusOpening:
            [self ShowMsg:@"connecting to PLC Command server, please wait a minute"];
            break;
        case NSStreamStatusOpen:
            break;
        case NSStreamStatusReading:
            [self ShowMsg:@"local cell busy"];
            break;
        case NSStreamStatusWriting:
            [self ShowMsg:@"local cell busy"];
            break;
        case NSStreamStatusAtEnd:
            [self closeSocket];
            [self ShowMsg:@"PLC Command Server stop"];
            [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
            break;
        case NSStreamStatusClosed:
            [self closeSocket];
            [self ShowMsg:@"PLC Command Server close"];
            [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
            break;
        case NSStreamStatusError:
            [self closeSocket];
            [self ShowMsg:@"PLC Command Server error"];
            [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
            break;
        default:
            break;
    }
}

- (void)ConnectTimeout:(NSTimer *)timer Socket:(IASocketConnection*)socket
{
    [self closeSocket];
    [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
    [self ShowMsg:@"connect to PLC Command server timeout"];
}

- (void)opencompleted:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    [self performSelectorOnMainThread:@selector(SocketStatus:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
}

-(void)SocketStatus:(NSNumber*)number
{
    if (isControltDelegate)
    {
        [delegate SocketControlUpdate:[number boolValue]];
    }
    else
    {
        NSLog(@"Update Socket Control:please add 'SocketControlUpdate' function");
    }
}

//- (void)SetCallback:(SEL)Callback Target:(id)object
//{
//    m_SocketCallBack = Callback;
//    m_CallbackTarget = object;
//}

- (void)setDelegate:(id)newDelegate
{
	id old = nil;
	if (newDelegate != delegate)
    {
		old = delegate;
//		delegate = [newDelegate retain];
        delegate = newDelegate;
        newDelegate = nil;
//		[old release];
        isControltDelegate = [delegate respondsToSelector:@selector(SocketControlUpdate:)];
        isCallbackDelegate = [delegate respondsToSelector:@selector(ReceiveDataCallback:)];
        isSendDataDelegate = [delegate respondsToSelector:@selector(SendData:)];
	}
}


@end
