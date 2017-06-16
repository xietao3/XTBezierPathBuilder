//
//  XTBezierPathProducer.h
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface XTBezierPathProducer : NSObject
+ (NSMutableArray *)getBezierPathWithPoints:(NSArray *)points;

+ (CGFloat)getBezierPathLengthWithBezierPathPoints:(NSArray *)bezierPathPoints;

@end
