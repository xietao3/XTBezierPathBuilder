//
//  DrawBezierManager.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/12.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "DrawBezierManager.h"

@interface DrawBezierManager ()

// 发动机
@property (nonatomic, strong) CADisplayLink *displayLink;
// 进度
@property (nonatomic, assign) CGFloat progress;
// 最终贝塞尔曲线的点的集合
@property (nonatomic, strong) NSMutableArray *bezierPathPoints;
// 中间阶层的点的集合 二阶数组
@property (nonatomic, strong) NSMutableArray *subLevelPoints;

#pragma mark - temp
// 手动加的点的集合
@property (nonatomic, weak) NSArray *touchPoints;

@property (nonatomic, weak) UIView *bezierView;

@property (nonatomic, strong) NSMutableArray *tempBezierPathPoints;

@end

@implementation DrawBezierManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)initial {
    
    _subLevelPoints = [[NSMutableArray alloc] init];
    _bezierPathPoints = [[NSMutableArray alloc] init];

    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.paused = YES;
    
    _progress = 0;
    _speed = 0.01;
}

#pragma mark - PublicMethod
- (void)cleanDataAndReloadView {
    [self stopDrawDisplayLink];
    [_subLevelPoints removeAllObjects];
    [_bezierPathPoints removeAllObjects];
    [self updateViewDisplay];

}

- (void)startDrawDisplayLinkWithTouchPoints:(NSArray *)touchPoints {
    _touchPoints = touchPoints;
    _progress = 0;
    _displayLink.paused = NO;
}

- (void)stopDrawDisplayLink {
    _displayLink.paused = YES;
}

- (BOOL)drawDisplayLinkPaused {
    return _displayLink.paused;
}

- (void)setBezierProgress:(CGFloat)progress {
    if (_bezierPathPoints.count == 0 || !self.displayLink.paused) return;
    
    _progress = progress;
    _subLevelPoints = [self getAllPointsWithOriginPoints:_touchPoints progress:_progress];
    NSInteger count = progress*100+1;
    _tempBezierPathPoints = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        [_tempBezierPathPoints addObject:_bezierPathPoints[i]];
    }
    
    if (_drawRectBlock) {
        _drawRectBlock(progress<1?_subLevelPoints:nil,_tempBezierPathPoints);
    }

}



#pragma mark - PrivateMethod
- (void)updateViewDisplay {
    if (_drawRectBlock) {
        _drawRectBlock(_subLevelPoints,_bezierPathPoints);
    }
}

- (void)updateDisplayLink {
    [self checkDisplayLineStop];
    
    _subLevelPoints = [self getAllPointsWithOriginPoints:_touchPoints progress:_progress];
    [self updateViewDisplay];
    _progress+=_speed;
    
}

- (void)checkDisplayLineStop {
    if (_progress > 1.0) {
        // 结束后 强行归1
        self.displayLink.paused = YES;
        _progress = 1.0;
        [self updateDisplayLink];
        
        // 删除部分阶级的线
        _progress = 1.0;
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.subLevelPoints removeAllObjects];
            [weakSelf updateViewDisplay];
        });
        return;
    }
}

/**
 获取根据touch点衍生出来所有的点
 
 @param points 手动点击的点
 @param progress 贝塞尔曲线当前进度
 @return pointArray
 */
- (NSMutableArray *)getAllPointsWithOriginPoints:(NSArray *)points progress:(CGFloat)progress{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSInteger level = points.count;
    
    NSArray *tempArray = points;
    for (int i = 0; i < level; i++) {
        tempArray = [self getsubLevelPointsWithSuperPoints:tempArray progress:progress];
        // 中间阶级的点
        [resultArray addObject:tempArray];

        if (tempArray.count == 1) {
            // 最终贝塞尔曲线的点
            [_bezierPathPoints addObjectsFromArray:tempArray];
            break;
        }
    }
    return resultArray;
}


/**
 根据上一级的点获取下一级的点
 
 @param points points
 @param progress progress
 @return array
 */
- (NSArray *)getsubLevelPointsWithSuperPoints:(NSArray *)points progress:(CGFloat)progress{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < points.count-1; i++) {
        NSValue *preValue = [points objectAtIndex:i];
        CGPoint prePoint = preValue.CGPointValue;
        
        NSValue *lastValue = [points objectAtIndex:i+1];
        CGPoint lastPoint = lastValue.CGPointValue;
        CGFloat diffX = lastPoint.x-prePoint.x;
        CGFloat diffY = lastPoint.y-prePoint.y;
        
        CGPoint currentPoint = CGPointMake(prePoint.x+diffX*progress, prePoint.y+diffY*progress);
        [tempArr addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
    return tempArr;
}


@end
