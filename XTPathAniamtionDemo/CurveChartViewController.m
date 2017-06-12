//
//  CurveChartViewController.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "CurveChartViewController.h"
#import "XTBezierPathProducer.h"

@interface CurveChartViewController ()

@end

@implementation CurveChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [XTBezierPathProducer getBezierPathWithPoints:@[]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
