//
//  ViewController.m
//  RMNavigation
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "ViewController.h"
#import "CustomViewController.h"
@interface ViewController ()
@property (nonatomic, assign) BOOL isHiddenBar;
@end

@implementation ViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:_isHiddenBar animated:YES];
    [self.navigationController.navigationBar setBarTintColor:[UIColor clearColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";

    UIButton *button = [[UIButton alloc] init];
    [self.view addSubview:button];
    [button setTitle:@"二级页" forState:UIControlStateNormal];
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

- (void)jumpToSecond {
    CustomViewController *vc = [[CustomViewController alloc] init];
    vc.view.backgroundColor = [UIColor orangeColor];
    vc.title = @"二级页";
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}
//- (void)willMoveToParentViewController:(UIViewController *)parent {
//    [super willMoveToParentViewController:parent];
//    NSLog(@"---%@",parent);
//}
@end
