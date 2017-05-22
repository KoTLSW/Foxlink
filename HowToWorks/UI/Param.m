//
//  Param.m
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Param.h"
//=============================================
@interface Param()
{
    NSString* _txt_path;
    NSString* _csv_path;
    NSString* _dut_type;
    NSString* _ui_title;
    NSString* _tester_version;
    NSString* _station;
    NSString* _stationID;
    NSString* _fixtureID;
    NSString* _lineNo;
    NSString* _sw_name;
    NSString* _sw_ver;
    
    NSString* _fixture_id;
    
    NSString* _file_path;
    
    NSString* _Gap1UpperLimit;
    NSString* _Gap1LowerLimit;
    NSString* _Gap1Unit;
    
    NSString* _Gap2UpperLimit;
    NSString* _Gap2LowerLimit;
    NSString* _Gap2Unit;
    
    NSString* _Gap3UpperLimit;
    NSString* _Gap3LowerLimit;
    NSString* _Gap3Unit;
    
    NSString* _Gap4UpperLimit;
    NSString* _Gap4LowerLimit;
    NSString* _Gap4Unit;
    
    NSString* _OHMUpperLimit;
    NSString* _OHMLowerLimit;
    NSString* _OHMUnit;
    
    NSString* _IP_MacWin;
    NSString* _Port_MacWin;
    
    BOOL      _pdca_is_upload;

}
@end
//=============================================
@implementation Param
//=============================================
@synthesize csv_path               = _csv_path;
@synthesize txt_path               = _txt_path;
@synthesize dut_type               = _dut_type;
@synthesize ui_title               = _ui_title;
@synthesize tester_version         = _tester_version;
@synthesize station                = _station;
@synthesize stationID              =_stationID;
@synthesize fixtureID              =_fixtureID;
@synthesize lineNo                 =_lineNo;
@synthesize sw_name                = _sw_name;
@synthesize sw_ver                 = _sw_ver;
@synthesize fixture_id             = _fixture_id;
@synthesize file_path              = _file_path;
@synthesize s_build                = _s_build;
@synthesize pdca_is_upload         = _pdca_is_upload;


@synthesize Gap1UpperLimit         =_Gap1UpperLimit;
@synthesize Gap1LowerLimit         =_Gap1LowerLimit;
@synthesize Gap1Unit               =_Gap1Unit;

@synthesize Gap2UpperLimit         =_Gap2UpperLimit;
@synthesize Gap2LowerLimit         =_Gap2LowerLimit;
@synthesize Gap2Unit               =_Gap2Unit;

@synthesize Gap3UpperLimit         =_Gap3UpperLimit;
@synthesize Gap3LowerLimit         =_Gap3LowerLimit;
@synthesize Gap3Unit               =_Gap3Unit;

@synthesize Gap4UpperLimit         =_Gap4UpperLimit;
@synthesize Gap4LowerLimit         =_Gap4LowerLimit;
@synthesize Gap4Unit               =_Gap4Unit;

@synthesize OHMUpperLimit         =_OHMUpperLimit;
@synthesize OHMLowerLimit         =_OHMLowerLimit;
@synthesize OHMUnit               =_OHMUnit;

@synthesize IP_MacWin             =_IP_MacWin;
@synthesize Port_MacWin           =_Port_MacWin;
//=============================================
- (void)ParamRead:(NSString*)filename
{
    //NSMutableArray *_testItems=[[NSMutableArray alloc]init];
    
    //首先读取plist中的数据
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    self.txt_path              = [dictionary objectForKey:@"txt_path"];
    self.csv_path               = [dictionary objectForKey:@"csv_path"];
    self.dut_type               = [dictionary objectForKey:@"dut_type"];
    self.ui_title               = [dictionary objectForKey:@"ui_title"];
    self.tester_version         = [dictionary objectForKey:@"ui_versiom"];
    self.station                = [dictionary objectForKey:@"station"];
    
    self.stationID              = [dictionary objectForKey:@"stationID"];
    self.fixtureID              = [dictionary objectForKey:@"fixtureID"];
    self.lineNo                 = [dictionary objectForKey:@"lineNO"];
    
    
    self.sw_name                = [dictionary objectForKey:@"sw_name"];
    self.sw_ver                 = [dictionary objectForKey:@"sw_ver"];
    
    
    
    //file_path
    self.file_path             =[dictionary objectForKey:@"file_path"];
    
    self.fixture_id             = [dictionary objectForKey:@"fixture_id"];
    
    self.pdca_is_upload         = [[dictionary objectForKey:@"pdca_is_upload"]boolValue];
    
    
    //上传SFC&PDCA项目相关变量定义
    self.Gap1UpperLimit         = [dictionary objectForKey:@"Gap1UpperLimit"];
    self.Gap1LowerLimit         = [dictionary objectForKey:@"Gap1LowerLimit"];
    self.Gap1Unit               = [dictionary objectForKey:@"Gap1Unit"];
    
    self.Gap2UpperLimit         = [dictionary objectForKey:@"Gap2UpperLimit"];
    self.Gap2LowerLimit         = [dictionary objectForKey:@"Gap2LowerLimit"];
    self.Gap2Unit               = [dictionary objectForKey:@"Gap2Unit"];
    
    self.Gap3UpperLimit         = [dictionary objectForKey:@"Gap3UpperLimit"];
    self.Gap3LowerLimit         = [dictionary objectForKey:@"Gap3LowerLimit"];
    self.Gap3Unit               = [dictionary objectForKey:@"Gap3Unit"];
    
    self.Gap4UpperLimit         = [dictionary objectForKey:@"Gap4UpperLimit"];
    self.Gap4LowerLimit         = [dictionary objectForKey:@"Gap4LowerLimit"];
    self.Gap4Unit               = [dictionary objectForKey:@"Gap4Unit"];
    
    self.OHMUpperLimit          = [dictionary objectForKey:@"OHMUpperLimit"];
    self.OHMLowerLimit          = [dictionary objectForKey:@"OHMLowerLimit"];
    self.OHMUnit                = [dictionary objectForKey:@"OHMUnit"];
    
    self.IP_MacWin              = [dictionary objectForKey:@"IP_MacWin"];
    self.Port_MacWin            = [dictionary objectForKey:@"Port_MacWin"];
    
}
//=============================================
- (void)ParamWrite:(NSString*)filename
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:_txt_path                                            forKey:@"txt_path"];
    [dictionary setObject:_csv_path                                            forKey:@"csv_path"];
    [dictionary setObject:_dut_type                                            forKey:@"dut_type"];
    [dictionary setObject:_ui_title                                            forKey:@"ui_title"];
    [dictionary setObject:_sw_name                                             forKey:@"sw_name"];
    [dictionary setObject:_sw_ver                                              forKey:@"sw_ver"];
    
    [dictionary setObject:_file_path forKey:@"file_path"];
    
    
    [dictionary setObject:_fixture_id                                          forKey:@"fixture_id"];
    
    
    [dictionary setObject:[NSNumber numberWithBool:_pdca_is_upload]            forKey:@"pdca_is_upload"];
    
    [dictionary writeToFile:plistPath atomically:YES];
}
//=============================================更改plist文件中的内容
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key
{
    //读取plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //添加内容
    [dictionary setObject:content forKey:key];
    [dictionary writeToFile:plistPath atomically:YES];
    
}

////=============================================
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key
//{
//    //读取plist
//    NSString *plistPath = [[NSBundle mainBundle]pathForResource:filename ofType:@"plist"];
//    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    
//    //添加内容
//    [dictionary setObject:content forKey:key];
//    
//    [dictionary writeToFile:plistPath atomically:YES];
//}
@end
//=============================================
