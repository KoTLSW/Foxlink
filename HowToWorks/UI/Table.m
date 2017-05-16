//
//  Table1.m
//  B312_BT_MIC_SPK
//
//  Created by EW on 16/5/12.
//  Copyright © 2016年 h. All rights reserved.
//

#import "Table.h"

//=============================================
@interface Table ()

@end
//=============================================
@implementation Table
//=============================================
@synthesize arrayDataSource=_arrayDataSource;
//=============================================
- (id)init:(NSView*)parent DisplayData:(NSArray*)arrayData
{
    
    
    self = [super init];
    
    if (self)
    {
        [self InitTableView:arrayData];
        
        [parent addSubview:self.view];
        
        self.view.translatesAutoresizingMaskIntoConstraints =NO;
        
        NSLayoutConstraint *constraint = nil;
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeLeading
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeLeading
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTrailing
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTrailing
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeTop
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeTop
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        constraint = [NSLayoutConstraint constraintWithItem:self.view
                                                  attribute:NSLayoutAttributeBottom
                                                  relatedBy:NSLayoutRelationEqual
                                                     toItem:parent
                                                  attribute:NSLayoutAttributeBottom
                                                 multiplier:1.0f
                                                   constant:0];
        [parent addConstraint:constraint];
        
        
        
        
        
        [self.table setColumnAutoresizingStyle:NSTableViewUniformColumnAutoresizingStyle];
        [self.table setAllowsColumnResizing:YES];
     //   NSArray* columns=[self.table tableColumns];
     //   for(int i=0;i<[columns count];i++)
      //  {
      //      [columns[i] setWidth:200];
      //  }
        
    }

    return self;
}
//=============================================
- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
    NSTableView* aTableView = aNotification.object;
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,aTableView.numberOfRows)];
    [aTableView noteHeightOfRowsWithIndexesChanged:indexes];
    
    NSLog(@"aaa");
}
//=============================================
-(void)InitTableView:(NSArray*)arrayData
{
    _arrayDataSource =[[NSMutableArray alloc] init];
    int countDisplay=1;
    
    for (int i=0; i<[arrayData count]; i++)
    {
        
        Item* item=[arrayData objectAtIndex:i];
        
        if( (item.isNeedShow == YES)&&(item.isNeedTest == YES) )
        {
            NSMutableDictionary* dic=[[NSMutableDictionary alloc] init];
            [dic setValue:[NSString stringWithFormat:@"%d",countDisplay] forKey:TABLE_COLUMN_ID];
            [dic setValue:item.testName?       item.testName:@""         forKey:TABLE_COLUMN_NAME];
            [dic setValue:item.testLowerLimit? item.testLowerLimit:@""   forKey:TABLE_COLUMN_LOWER_LIMIT];
            [dic setValue:item.testUpperLimit? item.testUpperLimit:@""   forKey:TABLE_COLUMN_UPPER_LIMIT];
            [dic setValue:item.testValueUnit?  item.testValueUnit:@""    forKey:TABLE_COLUMN_UNIT];
            [dic setValue:@""                                            forKey:TABLE_COLUMN_TEST_VALUE];
            [dic setValue:@""                                            forKey:TABLE_COLUMN_TEST_RESULT];
            [dic setValue:@""                                            forKey:TABLE_COLUMN_MESSAGE];
            
            [_arrayDataSource addObject:dic];
            
            countDisplay++;
        }
    }
    
    [self.table reloadData];
    
    [self.table needsDisplay];
}
//=============================================
-(void)SelectRow:(int)rowindex
{
    dispatch_async(dispatch_get_main_queue(), ^{

        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowindex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO];  // 选择指定行
        [self.table scrollRowToVisible:rowindex];                        // 滚动到指定行
        [self.table needsDisplay];
    });
}
//=============================================
-(void)flushTableView:(NSString*)strResultValue
          andTestName:(NSString*)strTestName
            andResult:(BOOL)isPass
        andUpperLimit:(NSString*)strUpperLimit
        andLowerLimit:(NSString*)strLowerLimit
          andRowIndex:(NSInteger)rowIndex
{
    NSDictionary* color = [NSDictionary dictionaryWithObjectsAndKeys:
                           isPass?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString* result = [[NSAttributedString alloc] initWithString:
                                  isPass?@"PASS":@"FAIL" attributes:color];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:strResultValue?strResultValue:@"" forKey:TABLE_COLUMN_TEST_VALUE];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:result?        result:@""         forKey:TABLE_COLUMN_TEST_RESULT];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:strUpperLimit? strUpperLimit:@""  forKey:TABLE_COLUMN_UPPER_LIMIT];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:strLowerLimit? strLowerLimit:@""  forKey:TABLE_COLUMN_LOWER_LIMIT];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowIndex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO]; // 选择指定行
        [self.table scrollRowToVisible:rowIndex];// 滚动到指定行
        [self.table reloadData];
        [self.table needsDisplay];
    });
}
//=============================================
-(void)flushTableRow:(Item*)item RowIndex:(NSInteger)rowIndex
{
    BOOL ispass = NO;
    
    if([item.testResult isEqualToString:@"PASS"])ispass=YES;
    
    NSDictionary* color = [NSDictionary dictionaryWithObjectsAndKeys:ispass?[NSColor greenColor]:[NSColor redColor],NSForegroundColorAttributeName, nil];
    
    NSAttributedString* result = [[NSAttributedString alloc] initWithString:ispass?@"PASS":@"FAIL" attributes:color];
    
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.testValue   forKey:TABLE_COLUMN_TEST_VALUE];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:result           forKey:TABLE_COLUMN_TEST_RESULT];
    //[[_arrayDataSource objectAtIndex:rowIndex] setValue:item.testResult  forKey:TABLE_COLUMN_TEST_RESULT];
    [[_arrayDataSource objectAtIndex:rowIndex] setValue:item.testMessage forKey:TABLE_COLUMN_MESSAGE];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexSet* indexSet = [[NSIndexSet alloc] initWithIndex:rowIndex];
        [self.table selectRowIndexes:indexSet byExtendingSelection:NO]; // 选择指定行
        [self.table scrollRowToVisible:rowIndex];// 滚动到指定行
        [self.table reloadData];
        [self.table needsDisplay];
    });
}
//=============================================
-(void)ClearTable
{
    for (int i=0; i<[_arrayDataSource count]; i++)
    {
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_TEST_VALUE];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_TEST_RESULT];
        [[_arrayDataSource objectAtIndex:i] setValue:@"" forKey:TABLE_COLUMN_MESSAGE];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.table reloadData];
    });
}
//=============================================
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_arrayDataSource count];
}
//=============================================
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([_arrayDataSource objectAtIndex:row]==nil)
        return @"";
    else
    {
        return [[_arrayDataSource objectAtIndex:row] objectForKey:[tableColumn identifier]];
    }
}
//=============================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}
//=============================================
@end
//=============================================


