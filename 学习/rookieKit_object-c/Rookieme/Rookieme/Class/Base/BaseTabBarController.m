//
//  BaseTabBarController.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "BaseTabBarController.h"
#import "JokeViewController.h"
#import "MineViewController.h"
@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self initViewControllers];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1.f)];
    view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
    [self.tabBar addSubview:view];
    
}


- (void)initViewControllers {
    self.tabBar.frame = CGRectMake(0,
                                   [UIScreen mainScreen].bounds.size.height - 50.f,
                                   [UIScreen mainScreen].bounds.size.width,
                                   50.f);
    self.tabBar.itemTitleColor = [UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:1.00];
    self.tabBar.itemTitleSelectedColor = [UIColor colorWithRed:0.07 green:0.67 blue:0.97 alpha:1.00];
    self.contentViewFrame = CGRectMake(0, StatusBarHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 50.f - StatusBarHeight);
    self.tabBar.itemTitleFont = [UIFont systemFontOfSize:12.f];
    
    JokeViewController *controller2 = [[JokeViewController alloc] init];
    controller2.yp_tabItemTitle = @"笑话";
    // 我的界面布局
    MineViewController *mineVC = [[MineViewController alloc] init];
    mineVC.yp_tabItemTitle = @"我的";
    
    self.viewControllers = [NSMutableArray arrayWithObjects:controller2, mineVC, nil];
    
}



- (void)yp_tabBar:(YPTabBar *)tabBar didSelectedItemAtIndex:(NSUInteger)index {
    [super yp_tabBar:tabBar didSelectedItemAtIndex:index];

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
