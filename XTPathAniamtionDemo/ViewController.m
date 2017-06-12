//
//  ViewController.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "ViewController.h"
#import "DrawBezierView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *bezierLevelLabel;

@property (nonatomic, strong) DrawBezierView *bezierView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bezierView = [[DrawBezierView alloc] initWithFrame:CGRectMake(0, 60, self.view.bounds.size.width, self.view.bounds.size.height-60)];
    [self.view addSubview:_bezierView];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)stepperValueChangedAction:(id)sender {
    UIStepper *stepper = sender;
    _bezierLevelLabel.text = [NSString stringWithFormat:@"%.0f阶",stepper.value-1];
    [_bezierView updatePointNumber:stepper.value];
}










@end
