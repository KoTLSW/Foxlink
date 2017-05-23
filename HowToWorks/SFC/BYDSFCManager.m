//
//  BYDSFCManager.m
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#import "BYDSFCManager.h"

static BYDSFCManager* bydSFC=nil;

@implementation BYDSFCManager
@synthesize SFCErrorType=_SFCErrorType;
@synthesize errorMessage = _errorMessage;
@synthesize SFCCheckType=_SFCCheckType;
@synthesize strUpdateBDA=_strUpdateBDA;//获取产品的BDA
@synthesize strMSEBDA=_strMSEBDA;//服务器BDA
//@synthesize strLogFileText=_strLogFileText;

- (id) init
{
    if (self = [super init])
    {
        _unit = [[BYDSFCUnit alloc] init];
        configPlist=[[PlistFile alloc] init:PLIST_CONFIG_FILE_NAME];
        
        if (configPlist != nil)
        {
            _unit.MESServerIP = [[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_SERVER_IP];
            _unit.BDAServerIP=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_BDA_SERVER_IP];
            _unit.netPort=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_NET_PORT];
            _unit.stationID=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_STATION_ID];
            _unit.stationName=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_STATION_NANE];
            _unit.cType=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_CTYPE];
            _unit.product=[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_PRODUCT];
        }
        
        _errorMessage = @"";
        _strSN=[[NSString alloc] init];
        _strUpdateBDA=[[NSString alloc] init];
//      _strLogFileText=[[NSMutableString alloc] initWithString:@""];
    }
    
    return self;
}


//Create static instance
+(BYDSFCManager*)Instance
{
    if(bydSFC==nil)
    {
        bydSFC=[[BYDSFCManager alloc] init];
    }
    
    return bydSFC;
}

//create an url
- (NSString *) createURL:(enum eSFC_Check_Type)sfcCheckType
                      sn:(NSString *)sn
              testResult:(NSString *)result
               startTime:(NSString *)tmStartStr
                 endTime:(NSString *)tmEndStr
               bdaSerial:(NSString*)strbdaSerial
           faiureMessage:(NSString *)failMsg

{
    NSLog(@"function: createURL");
    
    // SFC格式：SFC_URL=Http://10.1.1.21/foxlink/
     NSMutableString* urlString = [NSMutableString stringWithFormat:@"http://%@/foxlink/?",_unit.MESServerIP];          // ip
    
    switch (sfcCheckType)
    {
        case e_SN_CHECK:
        {
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,@"QUERY_RECORD"];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, [[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_STATION_ID]];
            [urlString appendFormat:@"%@=%@",SFC_TEST_P_TYPE,@"unit_process_check"];
        }
            break;

            //http:
            //192.168.229.253/Foxlink/?result=PASS&c=ADD_RECORD&sn=FL471850002HXNV1Q&product=B443&test_station_name=SMT-DEVELOPMENT6&station_id=FLDG_FQ3-5FAP-01_2_SMT-DEVELOPMENT6&mac_address=40:6c:8f:32:b3:cc&start_time=2017-04-1010:27:59&stop_time=2017-04-1010:28:41
 
        case  e_COMPLETE_RESULT_CHECK:
        {
            [urlString appendFormat:@"%@=%@&",SFC_TEST_RESULT,result];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_C_TYPE,@"ADD_RECORD"];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_SN, sn];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_PRODUCT,[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_PRODUCT]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_STATION_NAME,[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_STATION_NANE]];
            [urlString appendFormat:@"%@=%@&", SFC_TEST_STATION_ID, [[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_STATION_ID]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_MAC_ADDRESS,[_unit GetMacAddress]];
            [urlString appendFormat:@"%@=%@&",SFC_TEST_START_TIME,tmStartStr];
            [urlString appendFormat:@"%@=%@",SFC_TEST_STOP_TIME,tmEndStr];
    
        }
            break;
        default:
            break;
    }

    return urlString;
}


- (BOOL) submit:(NSString *)urlString
{
    NSLog(@"Function:submit");
    BOOL flag = NO;
    _isCheckPass = NO;
    //[[TestLog Instance] WriteLogResult:[GetTimeDay GetCurrentTime] andText:urlString];
    NSString* url = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    if (!urlRequest)
    {
        _errorMessage = [_errorMessage stringByAppendingString:@"error: Cann't connect the server.\r\n"];
        flag = NO;
        return flag;
    }
    
    [urlRequest setTimeoutInterval:10];
    [urlRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [urlRequest setNetworkServiceType:NSURLNetworkServiceTypeBackground];
    [urlRequest setHTTPMethod:@"POST"];
    
    // 单独处理请求任务
    NSThread* thrdSumbit = [[NSThread alloc] initWithTarget:self
            selector:@selector(handleHttpRequest:)object:urlRequest];
   
    if ([NSURLConnection canHandleRequest:urlRequest])
    {
        [thrdSumbit start];
    }
    
    // set timeout, timeout = 5s
    float time = 0;
    while (time < 5)
    {
        if (_isCheckPass)
        {
            if (_SFCErrorType==SFC_Success)
            {
                flag=YES;
            }

            break;
        }
        
        [NSThread sleepForTimeInterval:0.01];
        time += 0.01;
    }
    
    if (time==5 &&_SFCErrorType!=SFC_Success)
    {
        _SFCErrorType=SFC_TimeOut_Error;
    }
    
    return flag;
}

- (void) handleHttpRequest:(NSURLRequest *)urlRequest
{
    NSLog(@"Function:handleHttpRequest ");
    _isCheckPass = NO;
    [NSThread sleepForTimeInterval:0.3];
    NSData* byteRequest = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    NSString* backFromHttpStr = [[NSString alloc] initWithData:byteRequest encoding:NSUTF8StringEncoding];
    NSLog(@"HttpBackValue:%@",backFromHttpStr);
    
    NSMutableString* strLogFile=[[NSMutableString alloc] initWithFormat:@"HttpBackValue:%@\r\n",backFromHttpStr];

    if ([backFromHttpStr length]<1)
    {
        _SFCErrorType=SFC_ErrorNet;
    }
    else if([backFromHttpStr containsString:@"SFC_OK"])
    {
            _SFCErrorType=SFC_Success;
    }
    else if ([Regex RegexBoolResult:backFromHttpStr andRegex:@"Done"])
    {
        _SFCErrorType =SFC_SN_Error;
    }
    else if ([Regex RegexBoolResult:backFromHttpStr andRegex:@"ERROR"])
    {
        NSString* strResult=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<=：)(.*?)(?=,)"];
        
        if ([Regex RegexBoolResult:strResult andRegex:[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_FRONT_STATION_NAME]])
        {
            _SFCErrorType=SFC_StayInFrontStation;
        }
        else if ([Regex RegexBoolResult:strResult andRegex:[[configPlist ReadDictionary:CONFIG_SFC] objectForKey:CONFIG_SFC_NEXT_STATION_NAME]])
        {
            if (_SFCCheckType==e_COMPLETE_RESULT_CHECK)
            {
                _SFCErrorType=SFC_Success;
                NSLog(@"This is check Test result");
                [strLogFile appendString:@"This is check Test result\r\n"];
            }
            else
            {
               _SFCErrorType=SFC_StayInNextStation;
                 NSLog(@"This is check SN");
                [strLogFile appendString:@"This is check SN\r\n"];
            }
        }
        else if([Regex RegexBoolResult:backFromHttpStr andRegex:@"Exceeded"])
        {
            _SFCErrorType=SFC_OutOfTestCount;
        }
        else if([Regex RegexBoolResult:backFromHttpStr andRegex:@"exist"])
        {
            NSString* strBackBindSN=[Regex RegexStrResult:backFromHttpStr andRegex:@"(?<==)(.*?)(?=;)"];
            
            if (strBackBindSN!=nil && [strBackBindSN isEqualToString:_strSN])
            {
                _SFCErrorType=SFC_Success;
                NSLog(@"BDA Binding success");
                [strLogFile appendString:@"BDA Binding success\r\n"];

            }
            else
            {
                 _SFCErrorType=SFC_Exist_Error;
                 NSLog(@"BDA Binding error");
                [strLogFile appendString:@"BDA Binding error\r\n"];
            }
        }
        
        else
        {
            _SFCErrorType=SFC_SN_Error;
        }
    }
    
    //[[TestLog Instance] WriteLogResult:[GetTimeDay GetCurrentTime] andText:strLogFile];
    _isCheckPass = YES;

    [NSThread exit];
}

- (NSString *) timeToStr:(time_t)time
{
    struct tm* tm = localtime(&time);
    return [NSString stringWithFormat:@"%d-%d-%d %d:%d:%d", (tm->tm_year + 1900), (tm->tm_mon + 1),
            tm->tm_mday, tm->tm_hour, tm->tm_min, tm->tm_sec];
}


- (BOOL) checkSerialNumber:(NSString *)sn
{
    NSLog(@"Function: checkSerialNumber");
    
    NSString* url = [self createURL:e_SN_CHECK sn:sn testResult:nil
                          startTime:nil endTime:nil bdaSerial:nil faiureMessage:nil];
    NSLog(@"Check SerialNumber url:%@",url);
    return [self submit:url];
}

- (BOOL) checkComplete:(NSString *)sn
                result:(NSString *)result
             startTime:(time_t)tmStart
               endTime:(time_t)tmEnd
           failMessage:(NSString *)failMsg
{
    NSString* url = [self createURL:e_COMPLETE_RESULT_CHECK
                                 sn:sn testResult:result
                          startTime:[self timeToStr:tmStart]
                            endTime:[self timeToStr:tmEnd]
                            bdaSerial:nil
                      faiureMessage:failMsg];
    NSLog(@"CheckComplete url:%@",url);
    return [self submit:url];
}


@end
