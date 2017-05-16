//
//  Table1.h
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/12.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Item.h"
//=============================================
#define TABLE_COLUMN_ID             @"id"
#define TABLE_COLUMN_NAME           @"name"
#define TABLE_COLUMN_LOWER_LIMIT    @"lowerLimit"
#define TABLE_COLUMN_UPPER_LIMIT    @"upperLimit"
#define TABLE_COLUMN_UNIT           @"unit"
#define TABLE_COLUMN_TEST_VALUE     @"testValue"
#define TABLE_COLUMN_TEST_RESULT    @"testResult"
#define TABLE_COLUMN_MESSAGE        @"message"
//=============================================
@interface Table : NSViewController
{
    NSMutableArray*       _arrayDataSource;
}
//=============================================
@property(readwrite,copy)NSMutableArray* arrayDataSource;

@property (strong) IBOutlet NSView *custom;

@property (weak) IBOutlet NSScrollView *scrollview;
@property (weak) IBOutlet NSTableView *table;

//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData;
-(void)SelectRow:(int)rowindex;
-(void)flushTableView:(NSString*)strResultValue
          andTestName:(NSString*)strTestName
            andResult:(BOOL)isPass
        andUpperLimit:(NSString*)strUpperLimit
        andLowerLimit:(NSString*)strLowerLimit
          andRowIndex:(NSInteger)rowIndex;
-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex;
-(void)ClearTable;
-(void)InitTableView:(NSArray*)arrayData;
//=============================================
@end
