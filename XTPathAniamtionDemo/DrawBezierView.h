//
//  DrawBezierView.h
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/10.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawBezierView : UIView

// 速度
@property (nonatomic, assign) CGFloat speed;


/**
 设置点数量

 @param pointNumber pointNumber description
 */
- (void)updatePointNumber:(NSInteger)pointNumber;


/**
 设置当前贝塞尔曲线进去

 @param progress progress description
 */
- (void)setBezierProgress:(CGFloat)progress;
@end
