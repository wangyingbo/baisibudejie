//
//  TGSementBarVC.h
//  TGSegment
//
//  Created by targetcloud on 2017/4/19.
//  Copyright © 2017年 targetcloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TGSegmentBar.h"

@interface TGSementBarVC : UIViewController
@property (nonatomic, weak) TGSegmentBar *segmentBar;//供外界修改其父view
@property (nonatomic,assign) NSInteger defaultSelectedIndex;
- (void)setupWithItems: (NSArray <NSString *>*)items childVCs: (NSArray <UIViewController *>*)childVCs;
@end
