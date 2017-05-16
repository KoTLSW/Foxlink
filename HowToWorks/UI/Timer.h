//
//  Timer.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/13.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timer : NSObject
//=======================================
-(void)IrqTimer:(NSTimer *)timer;
-(void)StartTimer:(float)seconds;
-(void)StopTimer;
-(void)SetTime:(int)t;
-(int)GetTime;
//=======================================
@end
