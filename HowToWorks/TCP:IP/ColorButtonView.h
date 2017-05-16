//
//  ColorButtonView.h
//  TigerV
//
//  Created by Apple on 14-10-28.
//  Copyright (c) 2014年 zl. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ColorButtonView : NSButton
{
    NSImage *Green_Image;
    NSImage *Gray_Image;
    
    BOOL ConnectState;
}

-(void)SetButtonColor:(BOOL)State;
@end
