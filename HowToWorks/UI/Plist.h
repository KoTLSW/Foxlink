//
//  Plist.h
//  B312_BT_MIC_SPK
//
//  Created by h on 16/5/9.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Plist : NSObject
//=============================================
- (NSMutableArray*)PlistRead:(NSString*)filename Key:(NSString*)key;
- (void)PlistWrite:(NSString*)filename Item:(NSString*)item;
//=============================================
@end
