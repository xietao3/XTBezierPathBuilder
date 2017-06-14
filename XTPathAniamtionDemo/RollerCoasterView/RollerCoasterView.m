//
//  RollerCoasterView.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/14.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "RollerCoasterView.h"
#import "XTBezierPathProducer.h"
#import "RollerCoasterManager.h"

static const NSInteger pointRadius = 3.0;

@interface RollerCoasterView ()
// 上下文
@property (nonatomic, assign) CGContextRef currentContext;
// 手动加的点的集合
@property (nonatomic, strong) NSMutableArray *touchPoints;

@property (nonatomic, strong) NSMutableArray *allTouchPoints;

@property (nonatomic, strong) RollerCoasterManager *manager;

@property (nonatomic, strong) UIImageView *carImageView;

@end

@implementation RollerCoasterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)initial {
    __weak typeof(self) weakSelf = self;
    _touchPoints = [[NSMutableArray alloc] init];
    _allTouchPoints = [[NSMutableArray alloc] init];
    _manager = [[RollerCoasterManager alloc] init];
    _manager.updateCarPositionBlock = ^(NSValue *posotion){
        [weakSelf.carImageView setCenter:posotion.CGPointValue];
    };
    
    _carImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-25, -20, 25, 20)];
    [_carImageView setImage:[UIImage imageNamed:@"Car"]];
    [self addSubview:_carImageView];
    _carImageView.hidden = YES;

}

#pragma mark - PublicMethod
- (void)cleanPointsAndReloadView {
    if (![_manager drawDisplayLinkPaused]) return;
    _carImageView.hidden = YES;
    [_touchPoints removeAllObjects];
    [_allTouchPoints removeAllObjects];
    [self setNeedsDisplay];
}

- (void)switchNewBezierLine {
    if (![_manager drawDisplayLinkPaused]) return;
    if (_touchPoints.count == 0) return;
    
    id lastObj = [_touchPoints lastObject];
    NSArray *bezierPathPoints = [XTBezierPathProducer getBezierPathWithPoints:_touchPoints];
    [_allTouchPoints addObject:bezierPathPoints];
    [_touchPoints removeAllObjects];
    [_touchPoints addObject:lastObj];
    [self setNeedsDisplay];

}

- (void)fire {
    if (![_manager drawDisplayLinkPaused]) return;
    [_manager startDrawDisplayLinkWithBezierPoints:_allTouchPoints];
    _carImageView.hidden = NO;
}

#pragma mark - PrivateMethod



#pragma mark - DrawMethod
- (void)drawRect:(CGRect)rect {
    _currentContext = UIGraphicsGetCurrentContext();
    
    [self drawPointAndLineWithPoints:_touchPoints lineColor:nil needDrawPoint:YES pointColor:nil];
    
    for (NSArray *points in _allTouchPoints) {
        // 得到贝塞尔曲线所有的点
        NSValue *firstPointValue = points[0];
        [self drawPoint:firstPointValue.CGPointValue];
        // 开始绘画贝塞尔曲线
        [self drawPointAndLineWithPoints:points lineColor:nil needDrawPoint:NO pointColor:nil];

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
    if (![_manager drawDisplayLinkPaused]) return;
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    [_touchPoints addObject:[NSValue valueWithCGPoint:touchPoint]];
    [self setNeedsDisplay];
}


@end
