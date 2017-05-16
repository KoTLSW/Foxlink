//
//  LoginViewController.m
//  HowToWorks
//
//  Created by h on 17/3/28.
//  Copyright © 2017年 bill. All rights reserved.
//
#import "LoginViewController.h"
#import "WindowController.h"
#import "AppDelegate.h"
#import "Alert.h"
#import "Common.h"
#import "TestContext.h"
@interface LoginViewController()
{
    AppDelegate *appdelegate;
    CTestContext *ctestcontext;
}

@property(weak) IBOutlet NSImageView *headImageView;

@end

@implementation LoginViewController
-(void)viewDidLoad{
    //隐藏菜单
    [NSMenu setMenuBarVisible:NO];
    
    ctestcontext = new CTestContext();
    
    [super viewDidLoad];
    [self initview];
    [ErrorMsg setStringValue:@""];
    
    //初始化用户信息
    m_pUserInformation = new CUserInformation();
//    pCurrUser = m_pUserInformation->GetCurrentUser();
}

#pragma mark - 初始化视图
-(void)initview{
    
    //设置背景颜色
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    //头像圆边
    self.headImageView.wantsLayer = YES;
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width / 2;
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.borderWidth = 2;
    self.headImageView.layer.borderColor = [NSColor lightGrayColor].CGColor;
    
}

#pragma mark -  点击了登录Button
-(IBAction)loginButtonClicked:(NSButton *)sender{
    
    USER_INFOR u;
    memset(&u, 0, sizeof(u));
    strcpy(u.szName, [[UserName stringValue]UTF8String]);
    strcpy(u.szPassword, [[PassWord stringValue]UTF8String]);
    if(m_pUserInformation->CheckUser(u))
    {
        //设置用户名，用户密码，用户权限等级
        USER_INFOR *pCurr = m_pUserInformation->GetCurrentUser();
        [ctestcontext->m_dicConfiguration setValue:[NSString stringWithUTF8String:pCurr->szName] forKey:kContextUserName] ;
        [ctestcontext->m_dicConfiguration setValue:[NSString stringWithUTF8String:pCurr->szPassword] forKey:kContextUserPassWord];
        [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInt:pCurr->Authority] forKey:kContextAuthority];
        
        //1.创建聊天界面窗口控制器
        WindowController *UIwinController = [WindowController windowController];
        
        //2.强应用这个Window,不然这个Window会在跳转之后ide瞬间被销毁
        AppDelegate *appdelegate = (AppDelegate*)[NSApplication sharedApplication].delegate;
        appdelegate.mainWindowController = UIwinController;
        
        //3.设为KeyWindow并前置
        
        
        [UIwinController.window makeKeyAndOrderFront:self];
        
        //4.关闭现在的登录窗口
        [self.view.window orderOut:self];
        
    }
    else
    {
        [ErrorMsg setStringValue:@"用户名或密码错误，请重新输入!!!"];
        [ErrorMsg setTextColor:[NSColor redColor]];
    }
}


#pragma mark - 关闭窗口
-(IBAction)closeWindow:(id)sender{
    exit(0);
}


@end
