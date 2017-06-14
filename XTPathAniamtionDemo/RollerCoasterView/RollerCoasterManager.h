//
//  RollerCoasterManager.h
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/15.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^UpdateCarPositionBlock)(NSValue *);


@interface RollerCoasterManager : NSObject

@property (nonatomic, copy) UpdateCarPositionBlock updateCarPositionBlock;

- (void)startDrawDisplayLinkWithBezierPoints:(NSArray *)bezierPoints;

- (void)stopDrawDisplayLink;

- (BOOL)drawDisplayLinkPaused;

@end
