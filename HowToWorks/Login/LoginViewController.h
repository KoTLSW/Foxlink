//
//  LoginViewController.h
//  HowToWorks
//
//  Created by h on 17/3/28.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UserInformation.h"

@interface LoginViewController : NSViewController
{
    IBOutlet NSTextField *UserName;      //用户名
    IBOutlet NSTextField *PassWord;      //密码
    IBOutlet NSTextField *ErrorMsg;      //密码或用户名错误提醒
    
    USER_INFOR *pCurrUser;
    CUserInformation *m_pUserInformation;
    

}

@end
