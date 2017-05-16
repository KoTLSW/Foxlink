//
//  UserInformation.cpp
//  UI
//
//  Created by Ryan on 13-3-12.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//
#include "UserInformation.h"


CUserInformation::CUserInformation()
{
//    std::cout<<"ahfsdhsfhsdf"<<std::endl;
    
    m_arrUserList = [NSMutableArray new];
    
    USER_INFOR user3={"123","123",AUTHORITY_ADMIN};
    USER_INFOR user0={"admin","intelligent",AUTHORITY_ENGINEER};
    USER_INFOR user1={"engineer","intelligent",AUTHORITY_ENGINEER};
    USER_INFOR user2={"op","op",AUTHORITY_OPERATOR};    
    this->AddUser(user0);
    this->AddUser(user1);
    this->AddUser(user2);
    this->AddUser(user3);
    m_pCurrentUser = (USER_INFOR *)[[m_arrUserList objectAtIndex:0] bytes]; //default op
//    m_pCurrentUser = NULL;
}

CUserInformation::~CUserInformation()
{
    [m_arrUserList release];
}

int CUserInformation::AddUser(USER_INFOR u)
{
    NSData * d = [NSData dataWithBytes:&u length:sizeof(u)];
    [m_arrUserList addObject:d];
    return 0;
}

int CUserInformation::RemoveUser(const char * szName)
{
    USER_INFOR * puser = this->FindUser(szName);
    if (!puser) return -1;
    else {
        [m_arrUserList removeObject:[NSData dataWithBytes:puser length:sizeof(USER_INFOR)]];
    }
    return 0;
}

int CUserInformation::UpdateUser(USER_INFOR u)
{
    USER_INFOR * puser = this->FindUser(u.szName);
    if (!puser) return -1;
    strcpy(puser->szPassword, u.szPassword);
    puser->Authority = u.Authority;
    return 0;
}

int CUserInformation::LoadFromFile(const char *szpath)
{
    NSArray * arr = [NSArray arrayWithContentsOfFile:[NSString stringWithUTF8String:szpath]];
    if (arr)
    {
        [m_arrUserList removeAllObjects];
        [m_arrUserList addObjectsFromArray:arr];
    }
    return 0;
}

int CUserInformation::SaveToFile(const char *szpath)
{
    [m_arrUserList writeToFile:[NSString stringWithUTF8String:szpath] atomically:NO];
    return 0;
}

NSArray * CUserInformation::GetUserList()
{
    NSMutableArray * arr  = [NSMutableArray array];
    for (NSData * d in m_arrUserList)
    {
        USER_INFOR * puser = (USER_INFOR *)[d bytes];
        NSDictionary * dicUser = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:puser->szName],kLoginUserName,[NSString stringWithUTF8String:puser->szPassword],kLoginUserPassword,[NSNumber numberWithInt:puser->Authority],kLoginUserAuthority, nil];
        [arr addObject:dicUser];
    }
    return arr;
}

int CUserInformation::CheckUser(USER_INFOR u)
{
    USER_INFOR * pUser;
    for (NSData * d in m_arrUserList)
    {
        pUser = (USER_INFOR *)[d bytes];
        NSString * str1 = [[NSString stringWithUTF8String:pUser->szName] lowercaseString];
        NSString * str2 = [[NSString stringWithUTF8String:u.szName] lowercaseString];
        if ([str1 isEqualToString:str2])
        {
            if (strcmp(pUser->szPassword, u.szPassword)==0)
            {
                m_pCurrentUser = pUser;
                return YES;
            }
        }
    }
    return NO;
}

USER_INFOR * CUserInformation::FindUser(const char *szName)
{
    USER_INFOR * pUser;
    for (NSData * d in m_arrUserList)
    {
        pUser = (USER_INFOR *)[d bytes];
        NSString * str1 = [[NSString stringWithUTF8String:pUser->szName] lowercaseString];
        NSString * str2 = [[NSString stringWithUTF8String:szName] lowercaseString];
        if ([str1 isEqualToString:str2])
        {
                return pUser;
        }
    }
    return NULL;
}

USER_INFOR * CUserInformation::GetCurrentUser()
{
    return m_pCurrentUser;
}