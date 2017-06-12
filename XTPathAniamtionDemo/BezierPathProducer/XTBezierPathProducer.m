//
//  XTBezierPathProducer.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "XTBezierPathProducer.h"
@import UIKit;

@implementation XTBezierPathProducer

+ (NSMutableArray *)getBezierPathWithPoints:(NSArray *)points {
    NSMutableArray *bezierPathPoints = [[NSMutableArray alloc] init];
    for (float i = 0; i <= 1.0; i+=0.01) {
        [bezierPathPoints addObjectsFromArray:[self getAllPointsWithOriginPoints:points progress:i]];
    }
    return bezierPathPoints;
}

/**
 获取根据touch点衍生出来所有的点
 
 @param points 手动点击的点
 @param progress 贝塞尔曲线当前进度
 @return pointArray
 */
+ (NSMutableArray *)getAllPointsWithOriginPoints:(NSArray *)points progress:(CGFloat)progress{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSInteger level = points.count;
    
    NSArray *tempArray = points;
    for (int i = 0; i < level; i++) {
        tempArray = [self getsubLevelPointsWithSuperPoints:tempArray progress:progress];

        if (tempArray.count == 1) {
            // 最终贝塞尔曲线的点
            [resultArray addObjectsFromArray:tempArray];
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

@end
