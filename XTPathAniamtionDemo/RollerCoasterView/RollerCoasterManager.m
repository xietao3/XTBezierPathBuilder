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
@property (nonatomic, assign) CGFloat progress;
// 速度
@property (nonatomic, assign) CGFloat speed;


@property (nonatomic, weak) NSArray *bezierPoints;

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
    //    _displayLink.preferredFramesPerSecond = 60;
    _displayLink.paused = YES;
    
    _progress = 0;
    _speed = 0.01;
}

#pragma mark - PublicMethod
- (void)startDrawDisplayLinkWithBezierPoints:(NSArray *)bezierPoints {
    _bezierPoints = bezierPoints;
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
    

    _progress+=_speed;
    
}

- (void)checkDisplayLineStop {
    if (_progress > 1.0) {
        // 结束后 强行归1
        self.displayLink.paused = YES;
        _progress = 1.0;
        [self updateDisplayLink];
        
    }
}


@end
