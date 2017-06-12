//
//  DrawBezierView.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/10.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "DrawBezierView.h"

static const NSInteger pointRadius = 3.0;


@interface DrawBezierView ()


// 上下文
@property (nonatomic, assign) CGContextRef currentContext;
// 发动机
@property (nonatomic, strong) CADisplayLink *displayLink;
// 手动加的点的集合
@property (nonatomic, strong) NSMutableArray *touchPoints;
// 进度
@property (nonatomic, assign) CGFloat progress;
// 限制手动加点的数量 控制贝塞尔曲线阶数
@property (nonatomic, assign) NSInteger pointLimitNumber;
// 颜色集合
@property (nonatomic, strong) NSArray *colors;
// 最终贝塞尔曲线的点的集合
@property (nonatomic, strong) NSMutableArray *bezierPathPoints;
// 中间阶层的点的集合 二阶数组
@property (nonatomic, strong) NSMutableArray *subLevelPoints;


@end

@implementation DrawBezierView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"DrawBezierView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        [self initial];
        [self setFrame:frame];
    }
    return self;
}

- (void)initial {
    _touchPoints = [[NSMutableArray alloc] init];
    _bezierPathPoints = [[NSMutableArray alloc] init];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = YES;

    _progress = 0;
    _speed = 0.01;
    _pointLimitNumber = 3;
    _colors = @[[UIColor redColor],[UIColor orangeColor],[UIColor yellowColor],[UIColor greenColor],[UIColor cyanColor],[UIColor blueColor],[UIColor purpleColor],[UIColor darkGrayColor],[UIColor brownColor]];
    
    _colors = @[[UIColor darkGrayColor],[UIColor brownColor],[UIColor purpleColor],[UIColor blueColor],[UIColor cyanColor],[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor]];
}


- (void)drawRect:(CGRect)rect {
    _currentContext = UIGraphicsGetCurrentContext();
    
    
    // touchPoint & touchLine
    [self drawPointAndLineWithPoints:_touchPoints lineColor:nil needDrawPoint:YES pointColor:nil];
    
    // subLevelLine
    for (NSArray *levelPoints in _subLevelPoints) {
        // 取不同颜色
        NSInteger colorIndex = MIN([_subLevelPoints indexOfObject:levelPoints], _colors.count-1);
        // 画各级点和线
        [self drawPointAndLineWithPoints:levelPoints lineColor:_colors[colorIndex] needDrawPoint:YES pointColor:_colors[colorIndex]];

    }
    
    // bezierLine
    // 画最终的贝塞尔曲线
    [self drawPointAndLineWithPoints:self.bezierPathPoints lineColor:[UIColor redColor] needDrawPoint:NO pointColor:nil];
    if (_progress < 1.0) {
        NSValue *pointValue = [self.bezierPathPoints lastObject];
        if (pointValue) [self drawPoint:pointValue.CGPointValue pointColor:[UIColor redColor]];
    }
    
}

#pragma mark - DrawMethod
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


#pragma mark - PublicMethod
- (void)updatePointNumber:(NSInteger)pointNumber {
    _pointLimitNumber = pointNumber;
    // 清理掉当前屏幕内容
    _displayLink.paused = YES;
    [_touchPoints removeAllObjects];
    [_subLevelPoints removeAllObjects];
    [_bezierPathPoints removeAllObjects];
    [self setNeedsDisplay];

}


#pragma mark - PrivateMethod
- (void)checkBezierPointCount {
    if (_touchPoints.count >= _pointLimitNumber) {
        [_touchPoints removeAllObjects];
        [_bezierPathPoints removeAllObjects];
    }
}

- (void)updateDisplayLink {
    [self checkDisplayLineStop];
    
    _subLevelPoints = [self getAllPointsWithOriginPoints:_touchPoints progress:_progress];
    [self setNeedsDisplay];
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
            [weakSelf setNeedsDisplay];
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
        if (tempArray.count > 1) {
            // 中间阶级的点
            [resultArray addObject:tempArray];
        }else{
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



#pragma mark - TouchMethod
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.displayLink.paused) return;
    [self checkBezierPointCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
   
    [_touchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
    [self setNeedsDisplay];

    if (_touchPoints.count == _pointLimitNumber) {
        _progress = 0;
        self.displayLink.paused = NO;
    }
    
}








@end
