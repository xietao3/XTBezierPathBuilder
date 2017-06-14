//
//  ChartView.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "ChartView.h"
#import "XTBezierPathProducer.h"

static const NSInteger pointRadius = 3.0;


@interface ChartView ()

// 上下文
@property (nonatomic, assign) CGContextRef currentContext;
// 手动加的点的集合
@property (nonatomic, strong) NSMutableArray *touchPoints;


@end

@implementation ChartView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)initial {
    _isCurveLine = YES;
    _touchPoints = [[NSMutableArray alloc] init];
}

#pragma mark - PublicMethod
- (void)cleanPointsAndReloadView {
    [_touchPoints removeAllObjects];
    [self setNeedsDisplay];
}



#pragma mark - DrawMethod
- (void)drawRect:(CGRect)rect {
    _currentContext = UIGraphicsGetCurrentContext();
    
    if (_isCurveLine) {
        [self drawBezierLineWithPoints:_touchPoints lineColor:nil needDrawPoint:YES pointColor:nil];
    }else{
        [self drawPointAndLineWithPoints:_touchPoints lineColor:nil needDrawPoint:YES pointColor:nil];
    }
    
}


/**
 根据点集合 画点和线快捷方式...
 
 @param points 点集合
 @param lineColor 线颜色
 @param needDrawPoint 是否需求画点
 @param pointColor 点颜色
 */
- (void)drawPointAndLineWithPoints:(NSArray *)points lineColor:(UIColor *)lineColor needDrawPoint:(BOOL)needDrawPoint pointColor:(UIColor *)pointColor {
    __weak typeof(self) weakSelf = self;
    
    [points enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 画点
        if (needDrawPoint) {
            NSValue *pointValue = obj;
            if (pointColor) {
                [weakSelf drawPoint:pointValue.CGPointValue pointColor:pointColor];
            }else{
                [weakSelf drawPoint:pointValue.CGPointValue];
            }
        }
        
        // 画线
        if (idx>0) {
            NSValue *startPointValue = points[idx-1];
            NSValue *endPointValue = points[idx];
            if (lineColor) {
                [weakSelf drawLineWithStartPoint:startPointValue.CGPointValue endPoint:endPointValue.CGPointValue lineColor:lineColor];
            }else{
                [weakSelf drawLineWithStartPoint:startPointValue.CGPointValue endPoint:endPointValue.CGPointValue];
                
            }
        }
    }];
    
}

- (void)drawBezierLineWithPoints:(NSArray *)points lineColor:(UIColor *)lineColor needDrawPoint:(BOOL)needDrawPoint pointColor:(UIColor *)pointColor {
    __weak typeof(self) weakSelf = self;
    
    [points enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 画点
        if (needDrawPoint) {
            NSValue *pointValue = obj;
            if (pointColor) {
                [weakSelf drawPoint:pointValue.CGPointValue pointColor:pointColor];
            }else{
                [weakSelf drawPoint:pointValue.CGPointValue];
            }
        }
        
        // 画线
        if (idx>0) {
            NSValue *startPointValue = points[idx-1];
            NSValue *endPointValue = points[idx];
            CGPoint startPoint = startPointValue.CGPointValue;
            CGPoint endPoint = endPointValue.CGPointValue;

            // 插入两个控制点
            CGFloat diffX = endPoint.x-startPoint.x;
            NSValue *secondPointValue = [NSValue valueWithCGPoint:CGPointMake(startPoint.x+diffX/2.0, startPoint.y)];
            NSValue *thirdPointValue = [NSValue valueWithCGPoint:CGPointMake(startPoint.x+diffX/2.0, endPoint.y)];
            
            // 得到贝塞尔曲线所有的点
            NSArray *bezierPathPoints = [XTBezierPathProducer getBezierPathWithPoints:@[startPointValue,secondPointValue,thirdPointValue,endPointValue]];
            
            // 开始绘画贝塞尔曲线
            [self drawPointAndLineWithPoints:bezierPathPoints lineColor:nil needDrawPoint:NO pointColor:nil];
            
        }
    }];
    
}


- (void)drawPoint:(CGPoint)point {
    [self drawPoint:point pointColor:[UIColor lightGrayColor]];
}

- (void)drawPoint:(CGPoint)point pointColor:(UIColor *)pointColor{
    //创建点
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, point.x, point.y);
    CGContextAddArc(_currentContext, point.x, point.y, pointRadius, 0, 2*M_PI, 1);
    CGContextSetFillColorWithColor(_currentContext, pointColor.CGColor);
    CGContextAddPath(_currentContext, path);
    CGContextFillPath(_currentContext);
    CGPathRelease(path);
}

- (void)drawLineWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint {
    [self drawLineWithStartPoint:startPoint endPoint:endPoint lineColor:[UIColor lightGrayColor]];
}

- (void)drawLineWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint lineColor:(UIColor *)lineColor{
    //创建路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, startPoint.x, startPoint.y);
    CGPathAddLineToPoint(path, NULL, endPoint.x, endPoint.y);
    
    /*根据已存在的路径绘制路径
     */
    CGContextSetStrokeColorWithColor(_currentContext, lineColor.CGColor);
    CGContextSetLineWidth(_currentContext, 2);
    CGContextAddPath(_currentContext, path);
    CGContextStrokePath(_currentContext);
    CGPathRelease(path);
    
}

#pragma mark - TouchMethod
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    [_touchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
    [self setNeedsDisplay];
}

@end
