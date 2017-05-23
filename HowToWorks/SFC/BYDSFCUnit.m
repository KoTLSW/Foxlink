//
//  BYDSFCUnit.m
//  PDCA_Demo
//
//  Created by CW-IT-MB-046 on 14-12-25.
//  Copyright (c) 2014年 CW-IT-MB-046. All rights reserved.
//

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import "BYDSFCUnit.h"

@implementation BYDSFCUnit

@synthesize MESServerIP=_MESServerIP;
@synthesize cType=_cType;
@synthesize stationID=_stationID;
@synthesize stationName=_stationName;
@synthesize product=_product;
@synthesize macAddress=_macAddress;


- (id) init
{
    if (self = [super init])
    {
        _MESServerIP=@"10.1.1.21";
        _cType=[[NSString alloc] init];
        _stationID=[[NSString alloc] init];
        _stationName=[[NSString alloc] init];
        _product=[[NSString alloc]init];
        _macAddress=[[NSString alloc] init];
        
        
    }
    
    return self;
}

//GetIP
-(NSString*)GetServerIP
{
    if(_MESServerIP == nil)
    {
        _MESServerIP = @"10.1.1.21";
    }
    
     return _MESServerIP;
}

//get mac address
- (NSString *) GetMacAddress
{
//    if (_macAddress.length>0)
//    {
//        return _macAddress;
//    }
    
    int mgmtInfoBase[6];
    char* buf = NULL;
    unsigned char macAddr[6];
    size_t len;
    struct if_msghdr* interfareMsg;
    struct sockaddr_dl* sa_dl;
    NSString* errorFlag = NULL;
    
    // setup the management information base (mid)
    mgmtInfoBase[0] = CTL_NET;  // request network subsystem
    mgmtInfoBase[1] = AF_ROUTE; // routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;  // request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;
                                // request all configured interfaces
    mgmtInfoBase[5] = if_nametoindex("en0");
                                // with all configured interaces requested, get handle index
    
    if (!mgmtInfoBase[5])
    {
        errorFlag = @"if_nametoindex failure.\n";
    }
    else
    {
        // get the size of the data available
        if (sysctl(mgmtInfoBase, 6, NULL, &len, NULL, 0) < 0)
        {
            errorFlag = @"sysctl management information base failure.\n";
        }
        else
        {
            // alloc memory based on above call
            if ((buf = malloc(len)) == NULL)
            {
                errorFlag = @"allocate failure.\n";
            }
            else
            {
                //get system information
                if (sysctl(mgmtInfoBase, 6, buf, &len, NULL, 0) < 0)
                {
                    errorFlag = @"sysctl management information buffer failure.\n";
                }
            }
        }
    }
    
    if (errorFlag != NULL)
    {
        free(buf);
        NSLog(@"error: %@ - %@", self.className, errorFlag);
        _macAddress = nil;
        return _macAddress;
    }
    
    // map buffer to interface message structure
    interfareMsg = (struct if_msghdr *)buf;
    
    // map to link-level socket structure
    sa_dl = (struct sockaddr_dl *)(interfareMsg + 1);
    
    // copy link layer address data in socket structure to an array
    memcpy(&macAddr, sa_dl->sdl_data + sa_dl->sdl_nlen, 6);
    _macAddress = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                   macAddr[0], macAddr[1], macAddr[2], macAddr[3], macAddr[4], macAddr[5]];
    free(buf);
    return _macAddress;
}

@end
