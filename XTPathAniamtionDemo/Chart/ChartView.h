//
//  ChartView.h
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChartView : UIView

@property (nonatomic, assign) BOOL isCurveLine;

- (void)cleanPointsAndReloadView;
@end
