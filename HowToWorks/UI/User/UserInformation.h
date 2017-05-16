//
//  UserInformation.h
//  UI
//
//  Created by Ryan on 13-3-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#ifndef UI_UserInformation_h
#define UI_UserInformation_h
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "Common.h"
#import <iostream>

class CUserInformation {
public:
    CUserInformation();
    ~CUserInformation();
    
public:
    int AddUser(USER_INFOR u);
    int RemoveUser(const char * szName);
    int LoadFromFile(const char * szpath);
    int SaveToFile(const char * szpath);
    int CheckUser(USER_INFOR u);
    int UpdateUser(USER_INFOR u);
    USER_INFOR * FindUser(const char * szName);
    USER_INFOR * GetCurrentUser();
    NSArray * GetUserList();
protected:
    USER_INFOR * m_pCurrentUser;
    NSMutableArray * m_arrUserList;
    
};

#endif
