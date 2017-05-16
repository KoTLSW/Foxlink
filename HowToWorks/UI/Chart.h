//
//  Chart.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
//=======================================
@interface Chart : NSView
//=======================================
@property(readwrite,copy)NSString* title_top;
@property(readwrite,copy)NSString* title_left;
@property(readwrite,copy)NSString* title_bottom;
@property(readwrite)CGFloat        value_xmin;
@property(readwrite)CGFloat        value_xmax;
@property(readwrite)CGFloat        value_ymin;
@property(readwrite)CGFloat        value_ymax;
@property(readwrite)int            Separator_x;
@property(readwrite)int            Separator_y;
@property(readwrite)int            x_l;
@property(readwrite)int            x_r;
@property(readwrite)int            y_t;
@property(readwrite)int            y_b;
@property(readwrite)int            len;
//=======================================
- (id)initWithParent:(NSView*)parent
          title_top:(NSString*)top
         title_left:(NSString*)left
       title_bottom:(NSString*)bottom
               xmin:(float)xmin
               xmax:(float)xmax
               ymin:(float)ymin
               ymax:(float)ymax
        separator_x:(int)sx
        separator_y:(int)sy
             x_left:(int)x_left
            x_right:(int)x_right
              y_top:(int)y_top
           y_bottom:(int)y_bottom
             length:(int)length
            xformat:(NSString*)xf
            yformat:(NSString*)yf;

- (id)initWithFrame:(CGRect)frame
          title_top:(NSString*)top
         title_left:(NSString*)left
       title_bottom:(NSString*)bottom
               xmin:(float)xmin
               xmax:(float)xmax
               ymin:(float)ymin
               ymax:(float)ymax
        separator_x:(int)sx
        separator_y:(int)sy
             x_left:(int)x_left
            x_right:(int)x_right
              y_top:(int)y_top
           y_bottom:(int)y_bottom
             length:(int)length
            xformat:(NSString*)xf
            yformat:(NSString*)yf;

-(void)SetPoint:(int)index x:(float)value_x y:(float)value_y;
-(void)Repaint;
//=======================================
@end
