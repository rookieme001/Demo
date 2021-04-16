//
//  RMNavigationController.m
//  RMNavigation
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMNavigationController.h"
#import <objc/runtime.h>

#define rm_willPopKey @"rm_willMoveToParentViewController"
#define rm_didPopKey @"rm_didMoveToParentViewController"
#define rm_setBarTintColorKey @"rm_setBarTintColor"

@interface RMNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@property (nonatomic ,strong) id PopVCDelegate;
// 返回目标对象
@property (nonatomic, weak) UIViewController *targetController;
// 当前导航栏颜色
@property (nonatomic, strong) UIColor *currentColor;
// 目标导航栏颜色
@property (nonatomic, strong) UIColor *targetColor;
// 导航栏是否隐藏监听
@property (nonatomic, assign) BOOL isTargetControllerBarHidden;
// 侧滑返回渐变图层
@property (nonatomic, strong) UIView *gradientView;
@end

@implementation RMNavigationController

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换方法
        SEL originalSelector = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL swizzledSelector = NSSelectorFromString(@"rm_updateInteractiveTransition:");
        
        Method originalMethod  = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    });
}
- (void)rm_updateInteractiveTransition:(CGFloat)percentComplete {
    [self rm_updateInteractiveTransition:(percentComplete)];
    NSLog(@"percentComplete");
    
    UIColor *color = [self getCurrentColor:percentComplete];
    if (color) {
        [self.navigationBar setBarTintColor:color];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rm_willPop) name:rm_willPopKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rm_didPop) name:rm_didPopKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rm_setBarTintColor:) name:rm_setBarTintColorKey object:nil];
    
    self.PopVCDelegate = self.interactivePopGestureRecognizer.delegate;
    self.delegate      = self;
}

// 代理方法:导航控制器的View显示完毕时调用。 参数viewController要显示的控制器
-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //判断当前显示的控制器是否为根控制器.
    //清空滑动返回手势的代理就能实现
    self.interactivePopGestureRecognizer.delegate =  viewController == self.viewControllers[0]? self.PopVCDelegate : nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 控制器即将返回收到通知
 */
- (void)rm_willPop {
    NSInteger count = self.viewControllers.count;
    if (count >= 2) {
        _targetController = self.viewControllers[count-2];
    } else if (self.viewControllers.count){
        _targetController = self.viewControllers[0];
    }
}


/**
 控制器已经返回通知
 */
- (void)rm_didPop {
    // 返回结束，置空目标颜色和目标控制器
    _targetController = nil;
    _currentColor = _targetColor;
    _targetColor = nil;
    [self.navigationBar setBarTintColor:_currentColor];
}


/**
 设置导航栏颜色接收通知

 @param notice 信息
 */
- (void)rm_setBarTintColor:(NSNotification *)notice {
    UIColor *color = [notice object];
    // 当出现目标控制器时，触发颜色设置则重新配置目标颜色
    if (_targetController && !_targetColor) {
        _targetColor = color;
    } 
    
    // 当当前颜色为控制，默认现在颜色为当前颜色
    if (!_currentColor) {
        _currentColor = color;
    }
}


- (UIColor *)getCurrentColor:(CGFloat)percentComplete {

    if (!_currentColor || !_targetColor) {
        return nil;
    }

    CGFloat normalRed, normalGreen, normalBlue, normalAlpha;
    CGFloat selectedRed, selectedGreen, selectedBlue, selectedAlpha;

    [_currentColor getRed:&normalRed green:&normalGreen blue:&normalBlue alpha:&normalAlpha];

    // 如果目标导航栏隐藏，则不渐变导航栏颜色
    if (_isTargetControllerBarHidden) {
        [_currentColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:&selectedAlpha];
    } else {
        [_targetColor getRed:&selectedRed green:&selectedGreen blue:&selectedBlue alpha:&selectedAlpha];
    }

    // 获取选中和未选中状态的颜色差值
    CGFloat redDiff   = selectedRed - normalRed;
    CGFloat greenDiff = selectedGreen - normalGreen;
    CGFloat blueDiff  = selectedBlue - normalBlue;
    CGFloat alphaDiff = selectedAlpha - normalAlpha;

    NSLog(@"colorR:%.3f\ncolorG:%.3f\ncolorB:%.3f",percentComplete * redDiff + normalRed,percentComplete * greenDiff + normalGreen,percentComplete * blueDiff + normalBlue);


   return [UIColor colorWithRed:percentComplete * redDiff + normalRed
                          green:percentComplete * greenDiff + normalGreen
                           blue:percentComplete * blueDiff + normalBlue
                          alpha:percentComplete * alphaDiff + normalAlpha];

}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden {
    [super setNavigationBarHidden:navigationBarHidden];
    _isTargetControllerBarHidden = navigationBarHidden;
   
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    [super setNavigationBarHidden:hidden animated:animated];
    _isTargetControllerBarHidden = hidden;
}

@end
