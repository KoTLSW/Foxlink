//
//  PerformConfigDelegate.h
//  HowToWorks
//
//  Created by h on 17/4/10.
//  Copyright © 2017年 bill. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Common.h"

@interface PerformConfigDelegate : NSWindowController{
@private
    IBOutlet NSWindow *winConfig;
    IBOutlet NSButton *checkScanBarcode;
    IBOutlet NSButton *checkSFC;
    IBOutlet NSButton *checkPuddingPDCA;
    IBOutlet NSButton *checkDebugOut;
    IBOutlet NSMatrix *scriptSelect;
    IBOutlet NSTextField *csvpath;
}
-(IBAction)btCheck:(id)sender;
-(IBAction)btScriptSelect:(id)sender;
-(IBAction)btBrowse:(id)sender;
-(IBAction)btOK:(id)sender;
-(IBAction)btCancel:(id)sender;
@end
