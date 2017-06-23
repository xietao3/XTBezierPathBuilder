//
//  XTBezierPathProducer.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "XTBezierPathProducer.h"

@implementation XTBezierPathProducer

+ (NSMutableArray *)getBezierPathWithPoints:(NSArray *)points {
    
    // 先获取100个点组成的贝塞尔曲线
    NSMutableArray *preBezierPathPoints = [self getPreBezierPathWithPoints:points];
    
    // 获取贝塞尔曲线长度
    CGFloat length = [self getBezierPathLengthWithBezierPathPoints:preBezierPathPoints];
    
    // 根据长度获取分布均匀的贝塞尔曲线
    NSMutableArray *bezierPathPoints = [self getBezierPathWithPoints:points length:length];
    
    return bezierPathPoints;
}


/**
 获取100个点组成的贝塞尔曲线

 @param points 原始点集合
 @return return value description
 */
+ (NSMutableArray *)getPreBezierPathWithPoints:(NSArray *)points {
    // 先获取100个点组成的贝塞尔曲线
    NSMutableArray *bezierPathPoints = [[NSMutableArray alloc] init];
    for (float i = 0; i <= 1.0; i+=0.01) {
        [bezierPathPoints addObjectsFromArray:[self recursionGetsubLevelPointsWithSuperPoints:points progress:i]];
    }
    return bezierPathPoints;
}


/**
 根据长度获取分布均匀的贝塞尔曲线

 @param points 原始点集合
 @param length 长度
 @return return value description
 */
+ (NSMutableArray *)getBezierPathWithPoints:(NSArray *)points length:(CGFloat)length {
    // 先获取100个点组成的贝塞尔曲线
    CGFloat speed = 5.0/length;
    NSMutableArray *bezierPathPoints = [[NSMutableArray alloc] init];
    for (float i = 0; i <= 1.1; i+=speed) {
        if (i>1.0) {
            i = 1.0;
            [bezierPathPoints addObjectsFromArray:[self recursionGetsubLevelPointsWithSuperPoints:points progress:i]];
            break;
        }
        [bezierPathPoints addObjectsFromArray:[self recursionGetsubLevelPointsWithSuperPoints:points progress:i]];
    }
    return bezierPathPoints;

}


///**
// 获取根据touch点衍生出来所有的点
// 
// @param points 手动点击的点
// @param progress 贝塞尔曲线当前进度
// @return pointArray
// */
//+ (NSMutableArray *)getAllPointsWithOriginPoints:(NSArray *)points progress:(CGFloat)progress{
//    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
//    NSInteger level = points.count;
//    
//    NSArray *tempArray = points;
//    for (int i = 0; i < level; i++) {
//        tempArray = [self getsubLevelPointsWithSuperPoints:tempArray progress:progress];
//
//        if (tempArray.count == 1) {
//            // 最终贝塞尔曲线的点
//            [resultArray addObjectsFromArray:tempArray];
//            break;
//        }
//    }
//    return resultArray;
//}


+ (NSArray *)recursionGetsubLevelPointsWithSuperPoints:(NSArray *)points progress:(CGFloat)progress{
    if (points.count == 1) return points;
    
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
    return [self recursionGetsubLevelPointsWithSuperPoints:tempArr progress:progress];
}


/**
 根据上一级的点获取下一级的点
 
 @param points points
 @param progress progress
 @return array
 */
+ (NSArray *)getsubLevelPointsWithSuperPoints:(NSArray *)points progress:(CGFloat)progress{
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


/**
 获取贝塞尔曲线长度

 @param bezierPathPoints 点集合
 @return 长度
 */
+ (CGFloat)getBezierPathLengthWithBezierPathPoints:(NSArray *)bezierPathPoints {
    CGFloat length = 0;
    
    if (bezierPathPoints.count > 1) {
        for (int i = 0; i < bezierPathPoints.count - 1; i++) {
            NSValue *preValue = [bezierPathPoints objectAtIndex:i];
            CGPoint prePoint = preValue.CGPointValue;
            
            NSValue *lastValue = [bezierPathPoints objectAtIndex:i+1];
            CGPoint lastPoint = lastValue.CGPointValue;
            CGFloat diffX = lastPoint.x-prePoint.x;
            CGFloat diffY = lastPoint.y-prePoint.y;
            
            length+= sqrt(pow(diffX, 2)+pow(diffY, 2));

        }
    }
    return length;
}

@end
