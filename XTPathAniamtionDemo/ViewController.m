//
//  ViewController.m
//  XTPathAniamtionDemo
//
//  Created by xietao on 2017/6/6.
//  Copyright © 2017年 xietao3. All rights reserved.
//

#import "ViewController.h"
#import "DrawBezierViewController.h"
#import "CurveChartViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSArray *titleList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _titleList = @[@"绘制贝塞尔曲线",@"曲线图",@"过山车"];
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];


}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = _titleList[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // doSomething

    if (indexPath.row == 0) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DrawBezierViewController *goVC = [storyboard instantiateViewControllerWithIdentifier:@"DrawBezierViewController"];
        [self.navigationController pushViewController:goVC animated:YES];

    }else if (indexPath.row == 1) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CurveChartViewController *goVC = [storyboard instantiateViewControllerWithIdentifier:@"CurveChartViewController"];
        [self.navigationController pushViewController:goVC animated:YES];

    }else if (indexPath.row == 2) {

    }

}










@end
