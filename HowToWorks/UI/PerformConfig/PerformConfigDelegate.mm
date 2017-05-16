//
//  PerformConfigDelegate.m
//  HowToWorks
//
//  Created by h on 17/4/10.
//  Copyright © 2017年 bill. All rights reserved.
//

#import "PerformConfigDelegate.h"
#import "TestContext.h"


@interface PerformConfigDelegate ()
{
    CTestContext *ctestcontext;
    NSInteger scanStatus;
    NSInteger SFCStatus;
    NSInteger PDCAStatus;
    NSInteger DebugStatus;
}
@end

@implementation PerformConfigDelegate
-(id)init
{
    self = [super initWithWindowNibName:@"PerformConfigDelegate"];
    return self;
}


- (void)windowDidLoad
{
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(void)awakeFromNib
{
    [self InitialCtrls];
}
-(IBAction)btScriptSelect:(id)sender
{
    //把所选择的标号存到字典里，便于在其他地方取调用。
    NSInteger num = [scriptSelect selectedColumn];
    [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInteger:[scriptSelect selectedColumn] ] forKey:kContextscriptSelect];
    
    
    int num1 = [[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue];
}
-(IBAction)btCheck:(id)sender
{
    NSNumber *check = [NSNumber numberWithInt:[sender state]];
    switch ([sender tag]) {
        case 0:             //Scan Barcode?
                scanStatus = check.intValue;
            break;
        case 1:             //SFC ON
                SFCStatus = check.intValue;
            break;
        case 2:             //Pudding to PDCA
                PDCAStatus = check.intValue;

            break;
        case 3:             //Debug Out
                DebugStatus = check.intValue;

            break;
        default:
            break;
    }
}


-(IBAction)btBrowse:(id)sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:NO];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    
    [panel setDirectoryURL:[NSURL URLWithString:[csvpath stringValue]]];
    // This method displays the panel and returns immediately.
    // The completion handler is called when the user selects an
    // item or cancels the panel.
    [panel beginSheetModalForWindow:winConfig completionHandler:^(NSInteger result)
     //    [panel beginWithCompletionHandler:^(NSInteger result)
     {
         if (result == NSFileHandlingPanelOKButton) {
             @try {
                 NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
                 [csvpath setStringValue:[theDoc path]];
                 [ctestcontext->m_dicConfiguration setValue:[theDoc path] forKey:kContextCsvPath];
             }
             @catch (NSException *exception) {
                 NSRunAlertPanel(@"Load file", @"Load file failed,please check the data file formate", @"OK", nil, nil);
             }
             @finally {
             }
         }
     }];
}

-(IBAction)btOK:(id)sender
{
    [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInteger:scanStatus] forKey:kContextcheckScanBarcode];
    [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInteger:SFCStatus] forKey:kConTextcheckSFC];
    [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInteger:PDCAStatus] forKey:kContextcheckPuddingPDCA];
    [ctestcontext->m_dicConfiguration setValue:[NSNumber numberWithInteger:DebugStatus] forKey:kContextcheckDebugOut];
    //抛出消息
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationPreferenceChange object:nil];
    //4.关闭现在的登录窗口
    [self.window orderOut:self];
}

-(IBAction)btCancel:(id)sender
{
    //4.关闭现在的登录窗口
    [self.window orderOut:self];
}

//初始化函数，用于初始化字典中的值，及设置配置界面的状态
-(void)InitialCtrls
{
    //判断用户权限，进行相关设置
    
    int AuthorityLevel = [[ctestcontext->m_dicConfiguration valueForKey:kContextAuthority] intValue];
    if (AuthorityLevel==0 )
    {
        [checkScanBarcode setEnabled:YES];
        [checkSFC setEnabled:YES];
        [checkPuddingPDCA setEnabled:YES];
        [checkDebugOut setEnabled:YES];
        [scriptSelect setEnabled:YES];
    }
    else if (AuthorityLevel==1)
    {
        [checkScanBarcode setEnabled:YES];
        [checkSFC setEnabled:NO];
        [checkPuddingPDCA setEnabled:NO];
        [checkDebugOut setEnabled:YES];
        [scriptSelect setEnabled:NO];
    }
    else if (AuthorityLevel==2)
    {
        [checkScanBarcode setEnabled:NO];
        [checkSFC setEnabled:NO];
        [checkPuddingPDCA setEnabled:NO];
        [checkDebugOut setEnabled:NO];
        [scriptSelect setEnabled:NO];
    }
    
    //默认选择脚本
    [scriptSelect selectCellAtRow:0 column:[[ctestcontext->m_dicConfiguration valueForKey:kContextscriptSelect] intValue]];
    
    //设置以保存的路径，显示出来
    NSString *csvpathfromdic = [ctestcontext->m_dicConfiguration valueForKey:kContextCsvPath];
    if (csvpathfromdic.length!= 0)
    {
        [csvpath setStringValue:csvpathfromdic];
    }
    
    [checkScanBarcode setState:[[ctestcontext->m_dicConfiguration valueForKey:kContextcheckScanBarcode] intValue]];
    [checkSFC setState:[[ctestcontext->m_dicConfiguration valueForKey:kConTextcheckSFC] intValue]];
    [checkPuddingPDCA setState:[[ctestcontext->m_dicConfiguration valueForKey:kContextcheckPuddingPDCA]intValue]];
    [checkDebugOut setState:[[ctestcontext->m_dicConfiguration valueForKey:kContextcheckDebugOut] intValue]];
    scanStatus = checkScanBarcode.state;
    SFCStatus = checkSFC.state;
    PDCAStatus = checkPuddingPDCA.state;
    DebugStatus = checkDebugOut.state;
}

@end
