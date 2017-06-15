//
//  RollerCoasterManager.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/15.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "RollerCoasterManager.h"
@import UIKit;

@interface RollerCoasterManager ()
// 发动机
@property (nonatomic, strong) CADisplayLink *displayLink;
// 进度
@property (nonatomic, assign) NSInteger progress;
// 速度
@property (nonatomic, assign) CGFloat speed;


@property (nonatomic, strong) NSMutableArray *bezierPoints;

@end

@implementation RollerCoasterManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initial];
    }
    return self;
}

- (void)initial {
    
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateDisplayLink)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.preferredFramesPerSecond = 30;
    _displayLink.paused = YES;
    _bezierPoints = [[NSMutableArray alloc] init];
    _progress = 0;
    _speed = 1;
}

#pragma mark - PublicMethod
- (void)startDrawDisplayLinkWithBezierPoints:(NSArray *)bezierPoints {
    [_bezierPoints removeAllObjects];
    for (NSArray *arr in bezierPoints) {
        [_bezierPoints addObjectsFromArray:arr];
    }

    _progress = 0;
    _displayLink.paused = NO;
}

- (void)stopDrawDisplayLink {
    _displayLink.paused = YES;
}

- (BOOL)drawDisplayLinkPaused {
    return _displayLink.paused;
}

#pragma mark - PrivateMethod
- (void)updateDisplayLink {
    [self checkDisplayLineStop];
    
    [self updateViewDisplay];
    _progress+=_speed;
    
}

- (void)checkDisplayLineStop {
    NSInteger final = _bezierPoints.count-1;
    if (_progress > final) {
        // 结束后 强行归1
        self.displayLink.paused = YES;
        _progress = final;
        [self updateDisplayLink];
        
    }
}

- (void)updateViewDisplay {
    if (_updateCarPositionBlock) {
        _updateCarPositionBlock(_bezierPoints[MIN(_progress, _bezierPoints.count-1)]);
    }
}


@end
