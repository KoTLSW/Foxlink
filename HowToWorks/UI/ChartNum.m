//
//  Chart.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import "ChartNum.h"
//=======================================
@interface ChartNum (){
    
    NSString *_title_top;
    NSString *_title_left;
    NSString *_title_bottom;
    
    CGFloat _value_xmin;
    CGFloat _value_xmax;
    
    CGFloat _value_ymin;
    CGFloat _value_ymax;
    
    int     _Separator_x;
    int     _Separator_y;
    
    int     _x_l;
    int     _x_r;
    int     _y_t;
    int     _y_b;
    
    int     _len;
    float   x[4096];
    float   y_lower[4096];
    float   y_data[4096];
    float   y_upper[4096];
    
    float   _m;
    
    NSString  *xformat;
    NSString  *yformat;
}
@end
//=======================================
@implementation ChartNum
//=======================================
@synthesize title_top    = _title_top;
@synthesize title_left   = _title_left;
@synthesize title_bottom = _title_bottom;
@synthesize value_xmin   = _value_xmin;
@synthesize value_xmax   = _value_xmax;
@synthesize value_ymin   = _value_ymin;
@synthesize value_ymax   = _value_ymax;
@synthesize Separator_x  = _Separator_x;
@synthesize Separator_y  = _Separator_y;
@synthesize x_l          = _x_l;
@synthesize x_r          = _x_r;
@synthesize y_t          = _y_t;
@synthesize y_b          = _y_b;
@synthesize len          = _len;
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
             yformat:(NSString*)yf
{
    
    self = [super init];
    if (self) {
        
        self->_title_top=top;
        self->_title_left=left;
        self->_title_bottom=bottom;
        
        self->_value_xmin=xmin;
        self->_value_xmax=xmax;
        
        self->_value_ymin=ymin;
        self->_value_ymax=ymax;
        
        self->_Separator_x=sx;
        self->_Separator_y=sy;
        
        self->_x_l=x_left;
        self->_x_r=x_right;
        self->_y_t=y_top;
        self->_y_b=y_bottom;
        
        self->_len=length;
        
        for(int i=0;i<length;i++){
            x[i]=0;
            y_lower[i]=0;
            y_data[i]=0;
            y_upper[i]=0;
        }
        
        xformat=xf;
        yformat=yf;
    }
    
    [parent addSubview:self];
    
    self.translatesAutoresizingMaskIntoConstraints =NO;
    
    NSLayoutConstraint *constraint = nil;
    
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeLeading
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:parent
                                              attribute:NSLayoutAttributeLeading
                                             multiplier:1.0f
                                               constant:0];
    [parent addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTrailing
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:parent
                                              attribute:NSLayoutAttributeTrailing
                                             multiplier:1.0f
                                               constant:0];
    [parent addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:parent
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1.0f
                                               constant:0];
    [parent addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self
                                              attribute:NSLayoutAttributeBottom
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:parent
                                              attribute:NSLayoutAttributeBottom
                                             multiplier:1.0f
                                               constant:0];
    [parent addConstraint:constraint];
    
    return self;
}
//=======================================
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
            yformat:(NSString*)yf
{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self->_title_top=top;
        self->_title_left=left;
        self->_title_bottom=bottom;
        
        self->_value_xmin=xmin;
        self->_value_xmax=xmax;
        
        self->_value_ymin=ymin;
        self->_value_ymax=ymax;
        
        self->_Separator_x=sx;
        self->_Separator_y=sy;
        
        self->_x_l=x_left;
        self->_x_r=x_right;
        self->_y_t=y_top;
        self->_y_b=y_bottom;
        
        self->_len=length;
        
        for(int i=0;i<length;i++){
            x[i]=0;
            y_lower[i]=0;
            y_data[i]=0;
            y_upper[i]=0;
        }
        
        xformat=xf;
        yformat=yf;
    }
    
    return self;
}
//=======================================
- (void)drawRect:(NSRect)dirtyRect {
    
    //-------------------
    NSRect screen = [self bounds];         //获取View尺寸
    int SW = screen.size.width;
    int SH = screen.size.height;
    
    int sub_w=SW-(_x_l+_x_r);
    int sub_h=SH-(_y_t+_y_b);
    //-------------------
    [[NSColor lightGrayColor] set];        //设置View的背景颜色
    NSRectFill(screen);                    //填充整个View
    //-------------------
    NSRect sub=NSMakeRect(_x_l, _y_b, sub_w, sub_h);
    [[NSColor whiteColor] set];            //设置View的背景颜色
    NSRectFill(sub);                       //填充整个sub
    
    [[NSColor blackColor] set];            //设置sub的边框颜色
    //[NSBezierPath strokeLineFromPoint:NSMakePoint(20, 20)    toPoint:NSMakePoint(SW-20, 20)];
    //[NSBezierPath strokeLineFromPoint:NSMakePoint(20, SH-20) toPoint:NSMakePoint(SW-20, SH-20)];
    //[NSBezierPath strokeLineFromPoint:NSMakePoint(20, 20)    toPoint:NSMakePoint(20, SH-20)];
    //[NSBezierPath strokeLineFromPoint:NSMakePoint(SW-20, 20) toPoint:NSMakePoint(SW-20, SH-20)];
    //-------------------
    [_title_top drawAtPoint:NSMakePoint(SW/2-([_title_top length]/2)*8, SH-16) withAttributes:NULL];
    [_title_left drawAtPoint:NSMakePoint(_x_l, SH-_y_t) withAttributes:NULL];
    [_title_bottom drawAtPoint:NSMakePoint(SW-_x_r,_y_b) withAttributes:NULL];
    //-------------------
    float xdiv=(float)(_value_xmax-_value_xmin)/(float)(sub_w);    //X轴每个点代表的实际数值
    float ydiv=(float)(_value_ymax-_value_ymin)/(float)(sub_h);    //Y轴每个点代表的实际数值
    //-------------------
    for(int i=0;i<=_Separator_x;i++){
        
        float ex=(float)(_value_xmax-_value_xmin)/_Separator_x;     //每条分割线对应的比例
        
        float x1=(i*ex)/xdiv+_x_l;
        float y1=_y_b;
        
        float x2=(i*ex)/xdiv+_x_l;
        float y2=SH-_y_t;
        
        NSPoint point1 =NSMakePoint(x1, y1);
        NSPoint point2 =NSMakePoint(x2, y2);
        
        [[NSColor blueColor] set];
        [NSBezierPath setDefaultLineWidth:0.5];
        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
        
        NSString *xxx=[[NSString alloc]initWithFormat:xformat,ex*i+_value_xmin];
        
        [xxx drawAtPoint:NSMakePoint(x1-([xxx length]/2)*8,y1-16) withAttributes:NULL];
    }
    //-------------------
    for(int i=0;i<=_Separator_y;i++){
        
        float ey=(float)(_value_ymax-_value_ymin)/_Separator_y;     //每条分割线对应的比例
        
        float x1=_x_l;
        float y1=(i*ey)/ydiv+_y_b;
        
        float x2=SW-_x_r;
        float y2=(i*ey)/ydiv+_y_b;
        
        NSPoint point1 =NSMakePoint(x1, y1);
        NSPoint point2 =NSMakePoint(x2, y2);
        
        [[NSColor yellowColor] set];
        [NSBezierPath setDefaultLineWidth:0.5];
        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];
        
        NSString *yyy=[[NSString alloc]initWithFormat:yformat,ey*i+_value_ymin];
        
        [yyy drawAtPoint:NSMakePoint(x1-[yyy length]*8,y1-8) withAttributes:NULL];
    }
    //-------------------
    for(int i=0;i<_len-1;i++){
        
        float xx=_value_xmin;
        float yy=_value_ymin;
        //-----------------------
        float x1=(x[i]-xx)/xdiv+_x_l;
        float y1=(y_lower[i]-yy)/ydiv+_y_b;
        
        float x2=(x[i+1]-xx)/xdiv+_x_l;
        float y2=(y_lower[i+1]-yy)/ydiv+_y_b;
        
        NSPoint point1 =NSMakePoint(x1, y1);
        NSPoint point2 =NSMakePoint(x2, y2);
        
        [[NSColor blueColor] set];
        [NSBezierPath setDefaultLineWidth:1];
        [NSBezierPath strokeLineFromPoint:point1 toPoint:point2];       
        //-----------------------
        float x3=(x[i]-xx)/xdiv+_x_l;
        float y3=(y_data[i]-yy)/ydiv+_y_b;
        
        float x4=(x[i+1]-xx)/xdiv+_x_l;
        float y4=(y_data[i+1]-yy)/ydiv+_y_b;
        
        NSPoint point3 =NSMakePoint(x3, y3);
        NSPoint point4 =NSMakePoint(x4, y4);
        
        [[NSColor greenColor] set];
        [NSBezierPath setDefaultLineWidth:1];
        [NSBezierPath strokeLineFromPoint:point3 toPoint:point4];
        //-----------------------
        float x5=(x[i]-xx)/xdiv+_x_l;
        float y5=(y_upper[i]-yy)/ydiv+_y_b;
        
        float x6=(x[i+1]-xx)/xdiv+_x_l;
        float y6=(y_upper[i+1]-yy)/ydiv+_y_b;
        
        NSPoint point5 =NSMakePoint(x5, y5);
        NSPoint point6 =NSMakePoint(x6, y6);
        
        [[NSColor redColor] set];
        [NSBezierPath setDefaultLineWidth:1];
        [NSBezierPath strokeLineFromPoint:point5 toPoint:point6];
        //-----------------------
    }
    //-------------------
    //[self setNeedsDisplay:YES];// 强制绘画
    //-------------------
    
}
//=======================================
-(void)SetPoint:(int)index x:(float)value_x y_lower:(float)lower y_data:(float)data y_upper:(float)upper
{
    x[index]=value_x;
    
    y_lower[index]=lower;
    y_data[index]=data;
    y_upper[index]=upper;
    
}
//=======================================
-(void)Repaint{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay:YES];// 强制绘画
    });
}
//=======================================
-(void) mouseDragged:(NSEvent *)theEvent{
    //NSPoint mp = [self convertPoint:[theEvent locationInWindow] fromView:nil];// 鼠标新坐标
    //NSLog(@"mouseDragged~%f,%f",mp.x,mp.y);
    
}
//=======================================
-(void) mouseUp:(NSEvent *)theEvent{
    //NSLog(@"mouseUp");
    
}
//=======================================
-(void) mouseDown:(NSEvent *)theEvent{
    //NSLog(@"mouseDown");
    
}
//=======================================
@end
//=======================================
