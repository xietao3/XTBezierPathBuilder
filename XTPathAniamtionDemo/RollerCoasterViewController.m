//
//  RollerCoasterViewController.m
//  XTBezierPathBuilderDemo
//
//  Created by xietao on 2017/6/14.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "RollerCoasterViewController.h"
#import "RollerCoasterView.h"

@interface RollerCoasterViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *mScrollView;

@property (nonatomic, strong) RollerCoasterView *mView;

@end

@implementation RollerCoasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_mScrollView setContentSize:CGSizeMake(1000+self.view.bounds.size.width, self.view.bounds.size.height-124)];
    
    _mView = [[RollerCoasterView alloc] initWithFrame:CGRectMake(0, 0, _mScrollView.contentSize.width, _mScrollView.contentSize.height)];
    [_mView setBackgroundColor:[UIColor whiteColor]];
    [_mScrollView addSubview:_mView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(id)sender {
    UISlider *slider = sender;
    [_mScrollView setContentOffset:CGPointMake(slider.value, 0) animated:NO];
}

- (IBAction)newAction:(id)sender {
    [_mView switchNewBezierLine];
}

- (IBAction)startAction:(id)sender {
    
}

- (IBAction)clearAction:(id)sender {
    [_mView cleanPointsAndReloadView];

}

@end
