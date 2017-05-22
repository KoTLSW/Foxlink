//
//  Param.h
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Param : NSObject
//=============================================
@property(readwrite,copy)NSString*   txt_path;
@property(readwrite,copy)NSString*   csv_path;
@property(readwrite,copy)NSString*   dut_type;
@property(readwrite,copy)NSString*   ui_title;
@property(readwrite,copy)NSString*   tester_version;

@property(readwrite,copy)NSString*   station;
@property(readwrite,copy)NSString*   stationID;
@property(readwrite,copy)NSString*   fixtureID;
@property(readwrite,copy)NSString*   lineNo;

@property(readwrite,copy)NSString*  sw_name;
@property(readwrite,copy)NSString*  sw_ver;


//文件路径
@property(nonatomic,strong)NSString * file_path;


//sbuid
@property(nonatomic,strong)NSString * s_build;



@property(readwrite,copy)NSString*  fixture_id;


@property(readwrite)BOOL            pdca_is_upload;

//上传SFC&PDCA项目相关变量定义

@property(readwrite,copy)NSString*  Gap1UpperLimit;
@property(readwrite,copy)NSString*  Gap1LowerLimit;
@property(readwrite,copy)NSString*  Gap1Unit;

@property(readwrite,copy)NSString*  Gap2UpperLimit;
@property(readwrite,copy)NSString*  Gap2LowerLimit;
@property(readwrite,copy)NSString*  Gap2Unit;

@property(readwrite,copy)NSString*  Gap3UpperLimit;
@property(readwrite,copy)NSString*  Gap3LowerLimit;
@property(readwrite,copy)NSString*  Gap3Unit;

@property(readwrite,copy)NSString*  Gap4UpperLimit;
@property(readwrite,copy)NSString*  Gap4LowerLimit;
@property(readwrite,copy)NSString*  Gap4Unit;

@property(readwrite,copy)NSString*  OHMUpperLimit;
@property(readwrite,copy)NSString*  OHMLowerLimit;
@property(readwrite,copy)NSString*  OHMUnit;

//用于连接windows的IP和端口号
@property(readwrite,copy)NSString*  IP_MacWin;
@property(readwrite,copy)NSString*  Port_MacWin;






//=============================================
- (void)ParamRead:(NSString*)filename;
- (void)ParamWrite:(NSString*)filename;
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//=============================================
@end
