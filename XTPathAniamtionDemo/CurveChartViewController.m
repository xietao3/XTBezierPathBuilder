//
//  CurveChartViewController.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/13.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "CurveChartViewController.h"
#import "XTBezierPathProducer.h"
#import "ChartView.h"

@interface CurveChartViewController ()

@property (strong, nonatomic) IBOutlet UISegmentedControl *mSegmentControl;

@property (nonatomic, strong) ChartView *chartView;

@end

@implementation CurveChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitleView:self.mSegmentControl];
    _chartView = [[ChartView alloc] initWithFrame:CGRectMake(0,
                                                                       60,
                                                                       self.view.bounds.size.width,
                                                                       self.view.bounds.size.height-60)];
    _chartView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_chartView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segmentControl = sender;
    _chartView.isCurveLine = segmentControl.selectedSegmentIndex == 0;
    [_chartView cleanPointsAndReloadView];
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
