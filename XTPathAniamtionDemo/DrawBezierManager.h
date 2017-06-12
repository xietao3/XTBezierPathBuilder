//
//  DrawBezierManager.h
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/12.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef void(^DrawRectBlock)(NSArray *subLevelPoints,NSArray *bezierPathPoints);

@interface DrawBezierManager : NSObject

// 刷新ViewBlock
@property (nonatomic, copy) DrawRectBlock drawRectBlock;
// 速度
@property (nonatomic, assign) CGFloat speed;


/**
 清理数据并刷新
 */
- (void)cleanDataAndReloadView;


/**
 开始绘画曲线

 @param touchPoints touchPoints description
 */
- (void)startDrawDisplayLinkWithTouchPoints:(NSArray *)touchPoints;


/**
 暂停绘画曲线
 */
- (void)stopDrawDisplayLink;


/**
 绘画曲线DisplayLink是否暂停

 @return return value description
 */
- (BOOL)drawDisplayLinkPaused;

/**
 设置当前贝塞尔曲线进去
 
 @param progress progress description
 */
- (void)setBezierProgress:(CGFloat)progress;
@end
