//
//  Timer.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/13.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Timer.h"
//=============================================
@interface Timer()
{
    NSTimer *timer;
    int      time;
}
@end
//=============================================
@implementation Timer
//=============================================
// 定时器执行的方法
//=============================================
-(void)IrqTimer:(NSTimer *)timer
{
    
    time=time+1;
    //NSLog(@"定时器执行的方法");
    
    
}
//=============================================
// 开始定时器
//=============================================
-(void)StartTimer:(float)seconds
{
    //定义一个NSTimer
    timer = [NSTimer scheduledTimerWithTimeInterval:seconds
                                             target:self
                                           selector:@selector(IrqTimer:)
                                           userInfo:nil
                                            repeats:YES
             ];
    
//    + (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats
//    seconds：需要调用的毫秒数
//    target：调用方法需要发送的对象。即：发给谁
//    userInfo：发送的参数
//    repeats：指定定时器是否重复调用目标方法
}
//=============================================
// 停止定时器
//=============================================
-(void)StopTimer
{
    if(timer != nil){
        [timer invalidate];// 定时器调用invalidate后，就会自动执行release方法。不需要在显示的调用release方法
    }
}
//=============================================
-(void)SetTime:(int)t
{
    time=t;
}
//=============================================
-(int)GetTime
{
    return time;
}
//=============================================
@end
//=============================================