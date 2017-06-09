//
//  ViewController.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "ViewController.h"
#import "UIBezierPath+getAllPoints.h"

static const NSInteger pointLimitNumber = 5;

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) CAShapeLayer *bezierLayer;

@property (nonatomic, strong) UIBezierPath *bezierPointPath;
@property (nonatomic, strong) CAShapeLayer *bezierPointLayer;

@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat speed;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _bezierPointPath = UIBezierPath.bezierPath;
    _bezierPath = UIBezierPath.bezierPath;

    _points = [[NSMutableArray alloc] init];
    _progress = 0;
    _speed = 0.01;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CADisplayLink
- (void)startDisplayLink {
    self.displayLink.paused = NO;
}

- (void)stopDisplayLink {
    self.displayLink.paused = YES;
}



- (void)updateDisplayLink {
    if (_progress > 1.0) {
        [self stopDisplayLink];
        _progress = 1.0;
        [self updateDisplayLink];
        return;
    }

    [_bezierPointPath removeAllPoints];
    NSArray *allPoint = [self getAllPointsWithOriginPoints:_points progress:_progress];
    [self drawPoints:allPoint];
    _progress+=_speed;
    
}

- (NSArray *)getAllPointsWithOriginPoints:(NSArray *)points progress:(CGFloat)progress{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSInteger level = points.count;
    
    NSArray *tempArray = points;
    for (int i = 0; i < level; i++) {
        [resultArray addObject:tempArray];
        if (tempArray.count == 1) break;
        tempArray = [self getsubLevelPointsWithSuperPoints:tempArray progress:progress];
    }
    return resultArray;
}

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

- (void)drawPoints:(NSArray *)points {
    for (NSArray *subLevelPoints in points) {
        if (subLevelPoints.count > 1) {
            for (int i = 0; i < subLevelPoints.count-1; i++) {
                NSValue *preValue = [subLevelPoints objectAtIndex:i];
                CGPoint prePoint = preValue.CGPointValue;
                
                NSValue *lastValue = [subLevelPoints objectAtIndex:i+1];
                CGPoint lastPoint = lastValue.CGPointValue;
                
                [_bezierPointPath moveToPoint:prePoint];
                [_bezierPointPath addArcWithCenter:prePoint radius:2.0 startAngle:0 endAngle:0.1*M_PI clockwise:NO];
                [_bezierPointPath moveToPoint:lastPoint];
                [_bezierPointPath addArcWithCenter:lastPoint radius:2.0 startAngle:0 endAngle:0.1*M_PI clockwise:NO];
                
                [_bezierPointPath moveToPoint:prePoint];
                [_bezierPointPath addLineToPoint:lastPoint];
                
            }
        }else{
            NSValue *preValue = [subLevelPoints objectAtIndex:0];
            CGPoint prePoint = preValue.CGPointValue;
            if (_progress == 0) {
                [_bezierPath moveToPoint:prePoint];
            }else{
                [_bezierPath addLineToPoint:prePoint];
            }
//            [_bezierPath addArcWithCenter:prePoint radius:2.0 startAngle:0 endAngle:0.1*M_PI clockwise:NO];

            [self updateBezierPath];
        }
    }
    [self updatePointBezierPath];
    
}


#pragma mark - Touchs
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    [self checkBezierPointCount];
    
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    if (self.points.count == 0) {
        [_bezierPointPath moveToPoint:touchPoint];
    }else{
        [_bezierPointPath addLineToPoint:touchPoint];
    }
    [_bezierPointPath addArcWithCenter:touchPoint radius:2.0 startAngle:0 endAngle:0.1*M_PI clockwise:NO];
    [self.points addObject:[NSValue valueWithCGPoint:touchPoint]];
    [self updatePointBezierPath];
    
    if (_points.count == pointLimitNumber) {
        _progress = 0;
        [self startDisplayLink];
    }

}

- (void)updatePointBezierPath {
    if (_bezierPointLayer) {
        _bezierPointLayer.path = _bezierPointPath.CGPath;
        return;
    }

    _bezierPointLayer = [CAShapeLayer layer];
    _bezierPointLayer.strokeColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0].CGColor;
    _bezierPointLayer.fillColor = [UIColor clearColor].CGColor;
    _bezierPointLayer.lineWidth = 2.0;
    _bezierPointLayer.lineJoin = kCALineJoinRound;
    _bezierPointLayer.lineCap = kCALineCapRound;
    _bezierPointLayer.path = _bezierPointPath.CGPath;
    [self.view.layer addSublayer:_bezierPointLayer];

}

- (void)checkBezierPointCount {
    if (_points.count >= pointLimitNumber) {
        [_points removeAllObjects];
        [_bezierPath removeAllPoints];
        [_bezierPointPath removeAllPoints];
        [self updateBezierPath];
        [self updatePointBezierPath];

    }
}

- (void)updateBezierPath {
    if (_bezierLayer) {
        _bezierLayer.path = _bezierPath.CGPath;
        return;
    }
    
    _bezierLayer = [CAShapeLayer layer];
    _bezierLayer.strokeColor = [UIColor redColor].CGColor;
    _bezierLayer.fillColor = [UIColor clearColor].CGColor;
    _bezierLayer.lineWidth = 2.0;
    _bezierLayer.lineJoin = kCALineJoinRound;
    _bezierLayer.lineCap = kCALineCapRound;
    _bezierLayer.path = _bezierPath.CGPath;
    [self.view.layer addSublayer:_bezierLayer];
    
}








@end
