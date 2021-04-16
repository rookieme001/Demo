//
//  CustomViewController.m
//  RMNavigation
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "CustomViewController.h"

@interface CustomViewController ()
@property (nonatomic, assign) BOOL isHiddenBar;
@end

@implementation CustomViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor orangeColor]];
    [self.navigationController setNavigationBarHidden:_isHiddenBar animated:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc] init];
    [self.view addSubview:button];
    [button setTitle:@"三级页" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(jumpToSecond) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    
    UIButton *button2 = [[UIButton alloc] init];
    [self.view addSubview:button2];
    [button2 setTitle:@"显示导航栏" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button2 sizeToFit];
    [button2 addTarget:self action:@selector(showNavigationBar) forControlEvents:UIControlEventTouchUpInside];
    button2.center = CGPointMake(self.view.center.x, self.view.center.y+40.f);
    
    UIButton *button3 = [[UIButton alloc] init];
    [self.view addSubview:button3];
    [button3 setTitle:@"隐藏导航栏" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button3 sizeToFit];
    [button3 addTarget:self action:@selector(hiddenNavigationBar) forControlEvents:UIControlEventTouchUpInside];
    button3.center = CGPointMake(self.view.center.x, self.view.center.y+80.f);
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    NSLog(@"--->%@",parent);
}

- (void)jumpToSecond {
    CustomViewController *vc = [[CustomViewController alloc] init];
    vc.view.backgroundColor = [UIColor orangeColor];
    vc.title = @"三级页";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showNavigationBar{
    _isHiddenBar = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)hiddenNavigationBar {
    _isHiddenBar = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
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
