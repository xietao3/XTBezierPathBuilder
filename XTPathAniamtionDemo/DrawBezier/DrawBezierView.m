//
//  DrawBezierView.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/10.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "DrawBezierView.h"
#import "DrawBezierManager.h"

static const NSInteger pointRadius = 3.0;


@interface DrawBezierView ()
// 上下文
@property (nonatomic, assign) CGContextRef currentContext;
// 手动加的点的集合
@property (nonatomic, strong) NSMutableArray *touchPoints;
// 限制手动加点的数量 控制贝塞尔曲线阶数
@property (nonatomic, assign) NSInteger pointLimitNumber;
// 颜色集合
@property (nonatomic, strong) NSArray *colors;

@property (nonatomic, strong) DrawBezierManager *drawBezierManager;


#pragma mark - temp
// 最终贝塞尔曲线的点的集合
@property (nonatomic, weak) NSArray *bezierPathPoints;
// 中间阶层的点的集合 二阶数组
@property (nonatomic, weak) NSArray *subLevelPoints;


@end

@implementation DrawBezierView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self = [[[NSBundle mainBundle] loadNibNamed:@"DrawBezierView" owner:nil options:nil] objectAtIndex:0];
    if (self) {
        [self initial];
        [self setFrame:frame];
    }
    return self;
}

- (void)initial {
    __weak typeof(self) weakSelf = self;

    _touchPoints = [[NSMutableArray alloc] init];

    _pointLimitNumber = 3;
    
    _colors = @[[UIColor darkGrayColor],[UIColor brownColor],[UIColor purpleColor],[UIColor blueColor],[UIColor cyanColor],[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor redColor]];

    _drawBezierManager = [[DrawBezierManager alloc] init];
    _drawBezierManager.drawRectBlock = ^(NSArray *subLevelPoints,NSArray *bezierPathPoints){
        weakSelf.subLevelPoints = subLevelPoints;
        weakSelf.bezierPathPoints = bezierPathPoints;
        [weakSelf setNeedsDisplay];
    };
    
}

#pragma mark - PublicMethod
- (void)updatePointNumber:(NSInteger)pointNumber {
    _pointLimitNumber = pointNumber;
    // 清理掉当前屏幕内容
    [_touchPoints removeAllObjects];
    [_drawBezierManager cleanDataAndReloadView];
}

- (void)setBezierProgress:(CGFloat)progress {
    [_drawBezierManager setBezierProgress:progress];
}

#pragma mark - DrawMethod
- (void)drawRect:(CGRect)rect {
    _currentContext = UIGraphicsGetCurrentContext();
    
    
    // touchPoint & touchLine
    [self drawPointAndLineWithPoints:_touchPoints lineColor:nil needDrawPoint:YES pointColor:nil];
    
    // subLevelLine
    for (NSArray *levelPoints in _subLevelPoints) {
        if (levelPoints.count > 1) {
            // 取不同颜色
            NSInteger colorIndex = MIN([_subLevelPoints indexOfObject:levelPoints], _colors.count-1);
            // 画各级点和线
            [self drawPointAndLineWithPoints:levelPoints lineColor:_colors[colorIndex] needDrawPoint:YES pointColor:_colors[colorIndex]];
        }else{
            // 画最终的贝塞尔曲线的点
            NSValue *pointValue = [levelPoints lastObject];
            if (pointValue) [self drawPoint:pointValue.CGPointValue pointColor:[UIColor redColor]];
        }
    }
    // bezierLine
    // 画最终的贝塞尔曲线
    [self drawPointAndLineWithPoints:self.bezierPathPoints lineColor:[UIColor redColor] needDrawPoint:NO pointColor:nil];
    
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


#pragma mark - PrivateMethod
- (void)checkBezierPointCount {
    if (_touchPoints.count >= _pointLimitNumber) {
        // 清理掉当前屏幕内容
        [_touchPoints removeAllObjects];
        [_drawBezierManager cleanDataAndReloadView];
    }
}

#pragma mark - TouchMethod
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    // 绘画过程中停止新增点
    if (![_drawBezierManager drawDisplayLinkPaused]) return;
    [self checkBezierPointCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
   
    [_touchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
    [self setNeedsDisplay];

    if (_touchPoints.count == _pointLimitNumber) {
        [_drawBezierManager startDrawDisplayLinkWithTouchPoints:_touchPoints];
    }
    
}








@end
