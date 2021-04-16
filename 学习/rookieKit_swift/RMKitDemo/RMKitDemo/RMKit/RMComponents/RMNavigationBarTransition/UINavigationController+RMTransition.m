//
//  UINavigationController+RMTransition.m
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UINavigationController+RMTransition.h"
#import "UINavigationBar+RMTransition.h"
#import "UINavigationBar+RM.h"
#import "RMRuntime.h"
#import "UIImage+RM.h"
@interface RMTransitionNavigationBar : UINavigationBar

@end

@implementation RMTransitionNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    if (@available(iOS 11, *)) {
        // iOS 11 以前，自己 init 的 navigationBar，它的 backgroundView 默认会一直保持与 navigationBar 的高度相等，但 iOS 11 Beta 1-5 里，自己 init 的 navigationBar.backgroundView.height 默认一直是 44，所以才加上这个兼容
        self.rm_backgroundView.frame = self.bounds;
    }
}

@end

@interface UIViewController (RMTransition)
/// 用来模仿真的navBar的，在转场过程中存在的一条假navBar
@property(nonatomic, strong) RMTransitionNavigationBar *transitionNavigationBar;
/// 原始containerView的背景色
@property(nonatomic, strong) UIColor *originContainerViewBackgroundColor;
/// 是否要把真的navBar隐藏
@property(nonatomic, assign) BOOL prefersNavigationBarBackgroundViewHidden;
/// .m文件里自己赋值和使用。因为有些特殊情况下viewDidAppear之后，有可能还会调用到viewWillLayoutSubviews，导致原始的navBar隐藏，所以用这个属性做个保护。
@property(nonatomic, assign) BOOL lockTransitionNavigationBar;

@end

@implementation UIViewController (RMTransition)


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(viewWillLayoutSubviews) newSelector:@selector(NavigationBarTransition_viewWillLayoutSubviews)];
        
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(viewWillAppear:) newSelector:@selector(NavigationBarTransition_viewWillAppear:)];
        
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(viewDidAppear:) newSelector:@selector(NavigationBarTransition_viewDidAppear:)];
        
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(viewDidDisappear:) newSelector:@selector(NavigationBarTransition_viewDidDisappear:)];
        
//        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(viewWillDisappear:) newSelector:@selector(NavigationBarTransition_viewWillDisappear:)];
    });
}

- (UINavigationBar *)transitionNavigationBar {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setTransitionNavigationBar:(UINavigationBar *)transitionNavigationBar {
    objc_setAssociatedObject(self, @selector(transitionNavigationBar), transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)NavigationBarTransition_viewWillAppear:(BOOL)animated {
    
    // TODO： 放在最前面，留一个时机给业务可以覆盖
//    [self renderNavigationStyleInViewController:self animated:animated];
    [self NavigationBarTransition_viewWillAppear:animated];

}

- (void)NavigationBarTransition_viewDidAppear:(BOOL)animated {
    
    self.lockTransitionNavigationBar = YES;
    
    if (self.transitionNavigationBar) {
        
        [UIViewController replaceStyleForNavigationBar:self.transitionNavigationBar withNavigationBar:self.navigationController.navigationBar];
        [self removeTransitionNavigationBar];
        
        id <UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        [transitionCoordinator containerView].backgroundColor = self.originContainerViewBackgroundColor;
    }
    
    if ([self.navigationController.viewControllers containsObject:self]) {
        // 防止一些 childViewController 走到这里
        self.prefersNavigationBarBackgroundViewHidden = NO;
    }
    
    [self NavigationBarTransition_viewDidAppear:animated];
}

- (void)NavigationBarTransition_viewWillDisappear:(BOOL)animated {
    
    [self NavigationBarTransition_viewWillDisappear:animated];
    
    [self addTransitionNavigationBarIfNeeded];
//    [self resizeTransitionNavigationBarFrame];
//    self.navigationController.navigationBar.rm_transitionNavigationBar = self.transitionNavigationBar;
    self.prefersNavigationBarBackgroundViewHidden = YES;
}

- (void)NavigationBarTransition_viewDidDisappear:(BOOL)animated {
    
    self.lockTransitionNavigationBar = NO;
    
    if (self.transitionNavigationBar) {
        [self removeTransitionNavigationBar];
    }
    
    [self NavigationBarTransition_viewDidDisappear:animated];
}

- (void)NavigationBarTransition_viewWillLayoutSubviews {
    
    if ([self.navigationController.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        [self NavigationBarTransition_viewWillLayoutSubviews];
        
    } else {
        
        id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.transitionCoordinator;
        //        UIViewController *fromViewController = [transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        
        BOOL isCurrentToViewController = (self == toViewController);
        
        if (isCurrentToViewController && !self.lockTransitionNavigationBar) {
            
            
            if (!self.transitionNavigationBar) {
                [self addTransitionNavigationBarIfNeeded];
                [self resizeTransitionNavigationBarFrame];
                self.navigationController.navigationBar.rm_transitionNavigationBar = self.transitionNavigationBar;
                self.prefersNavigationBarBackgroundViewHidden = YES;
                
                [self NavigationBarTransition_viewWillLayoutSubviews];
            }
        }
    }
}

- (void)addTransitionNavigationBarIfNeeded {
    
    
    UINavigationBar *originBar = self.navigationController.navigationBar;
    RMTransitionNavigationBar *customBar = [[RMTransitionNavigationBar alloc] init];
    
    if (customBar.barStyle != originBar.barStyle) {
        customBar.barStyle = originBar.barStyle;
    }
    
    if (customBar.translucent != originBar.translucent) {
        customBar.translucent = originBar.translucent;
    }
    
    if (![customBar.barTintColor isEqual:originBar.barTintColor]) {
        customBar.barTintColor = originBar.barTintColor;
    }
    
    UIImage *backgroundImage = [originBar backgroundImageForBarMetrics:UIBarMetricsDefault];
    if (backgroundImage && backgroundImage.size.width <= 0 && backgroundImage.size.height <= 0) {
        // 假设这里的图片时通过`[UIImage new]`这种形式创建的，那么会navBar会奇怪地显示为系统默认navBar的样式。不知道为什么 navController 设置自己的 navBar 为 [UIImage new] 却没事，所以这里做个保护。
        backgroundImage = [UIImage rm_imageWithColor:[UIColor clearColor]];
    }
    [customBar setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    
    [customBar setShadowImage:originBar.shadowImage];
    
    self.transitionNavigationBar = customBar;
    [self resizeTransitionNavigationBarFrame];
    
    if (!self.navigationController.navigationBarHidden) {
        [self.view addSubview:self.transitionNavigationBar];
    }
}

- (void)resizeTransitionNavigationBarFrame {

    
    if (self.view.hidden || self.view.alpha <= 0.01) {
         self.transitionNavigationBar.frame = CGRectZero;
    }
    
    UIView *backgroundView = self.navigationController.navigationBar.rm_backgroundView;
    CGRect rect = [backgroundView.superview convertRect:backgroundView.frame toView:self.view];
    self.transitionNavigationBar.frame = rect;
}

- (void)removeTransitionNavigationBar {
    if (!self.transitionNavigationBar) {
        return;
    }
    [self.transitionNavigationBar removeFromSuperview];
    self.transitionNavigationBar = nil;
}

+ (void)replaceStyleForNavigationBar:(UINavigationBar *)navbarA withNavigationBar:(UINavigationBar *)navbarB {
    navbarB.barStyle = navbarA.barStyle;
    navbarB.barTintColor = navbarA.barTintColor;
    [navbarB setShadowImage:navbarA.shadowImage];
    [navbarB setBackgroundImage:[navbarA backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
}

#pragma mark - Setter / Getter

- (BOOL)lockTransitionNavigationBar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setLockTransitionNavigationBar:(BOOL)lockTransitionNavigationBar {
    objc_setAssociatedObject(self, @selector(lockTransitionNavigationBar), [[NSNumber alloc] initWithBool:lockTransitionNavigationBar], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)originContainerViewBackgroundColor {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setOriginContainerViewBackgroundColor:(UIColor *)originContainerViewBackgroundColor {
    objc_setAssociatedObject(self, @selector(originContainerViewBackgroundColor), originContainerViewBackgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)prefersNavigationBarBackgroundViewHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setPrefersNavigationBarBackgroundViewHidden:(BOOL)prefersNavigationBarBackgroundViewHidden {
    // 从某个版本开始，发现从有 navBar 的界面返回无 navBar 的界面，backgroundView 会跑出来，发现是被系统重新设置了显示，所以改用其他的方法来隐藏 backgroundView，就是 mask。
    if (prefersNavigationBarBackgroundViewHidden) {
        self.navigationController.navigationBar.rm_backgroundView.layer.mask = [CALayer layer];
    } else {
        self.navigationController.navigationBar.rm_backgroundView.layer.mask = nil;
    }
    objc_setAssociatedObject(self, @selector(prefersNavigationBarBackgroundViewHidden), [[NSNumber alloc] initWithBool:prefersNavigationBarBackgroundViewHidden], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (UIColor *)containerViewBackgroundColor {
    UIColor *backgroundColor = [UIColor blueColor];
//    if ([self conformsToProtocol:@protocol(QMUICustomNavigationBarTransitionDelegate)]) {
//        UIViewController<QMUICustomNavigationBarTransitionDelegate> *vc = (UIViewController<QMUICustomNavigationBarTransitionDelegate> *)self;
//        if ([vc respondsToSelector:@selector(containerViewBackgroundColorWhenTransitioning)]) {
//            backgroundColor = [vc containerViewBackgroundColorWhenTransitioning];
//        }
//    }
    return backgroundColor;
}

#pragma mark - 工具方法


@end

@implementation UINavigationController (RMTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [self class];
        [RMRuntime rm_exchangeInstanceMethod:cls originSelector:@selector(pushViewController:animated:) newSelector:@selector(NavigationBarTransition_pushViewController:animated:)];

        [RMRuntime rm_exchangeInstanceMethod:cls originSelector:@selector(setViewControllers:animated:) newSelector:@selector(NavigationBarTransition_setViewControllers:animated:)];
        [RMRuntime rm_exchangeInstanceMethod:cls originSelector:@selector(popViewControllerAnimated:) newSelector:@selector(NavigationBarTransition_popViewControllerAnimated:)];
        [RMRuntime rm_exchangeInstanceMethod:cls originSelector:@selector(popToViewController:animated:) newSelector:@selector(NavigationBarTransition_popToViewController:animated:)];
        [RMRuntime rm_exchangeInstanceMethod:cls originSelector:@selector(popToRootViewControllerAnimated:) newSelector:@selector(NavigationBarTransition_popToRootViewControllerAnimated:)];
    });
}

- (void)NavigationBarTransition_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {

    if ([self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self NavigationBarTransition_pushViewController:viewController animated:animated];
    }

    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_pushViewController:viewController animated:animated];
    }

//    BOOL shouldCustomNavigationBarTransition = [self shouldCustomTransitionAutomaticallyWithFirstViewController:disappearingViewController secondViewController:viewController];

//    if (shouldCustomNavigationBarTransition) {
        [disappearingViewController addTransitionNavigationBarIfNeeded];
        disappearingViewController.prefersNavigationBarBackgroundViewHidden = YES;
//    }

    return [self NavigationBarTransition_pushViewController:viewController animated:animated];
}

- (void)NavigationBarTransition_setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated {
    if (viewControllers.count <= 0 || !animated) {
        return [self NavigationBarTransition_setViewControllers:viewControllers animated:animated];
    }
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = viewControllers.lastObject;
    if (!disappearingViewController) {
        return [self NavigationBarTransition_setViewControllers:viewControllers animated:animated];
    }
    [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    return [self NavigationBarTransition_setViewControllers:viewControllers animated:animated];
}

- (UIViewController *)NavigationBarTransition_popViewControllerAnimated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = self.viewControllers.count >= 2 ? self.viewControllers[self.viewControllers.count - 2] : nil;
    if (disappearingViewController && appearingViewController) {
        [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    }
    return [self NavigationBarTransition_popViewControllerAnimated:animated];
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    UIViewController *appearingViewController = viewController;
    NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToViewController:viewController animated:animated];
    if (poppedViewControllers) {
        [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
    }
    return poppedViewControllers;
}

- (NSArray<UIViewController *> *)NavigationBarTransition_popToRootViewControllerAnimated:(BOOL)animated {
    NSArray<UIViewController *> *poppedViewControllers = [self NavigationBarTransition_popToRootViewControllerAnimated:animated];
    if (self.viewControllers.count > 1) {
        UIViewController *disappearingViewController = self.viewControllers.lastObject;
        UIViewController *appearingViewController = self.viewControllers.firstObject;
        if (poppedViewControllers) {
            [self handlePopViewControllerNavigationBarTransitionWithDisappearViewController:disappearingViewController appearViewController:appearingViewController];
        }
    }
    return poppedViewControllers;
}

- (void)handlePopViewControllerNavigationBarTransitionWithDisappearViewController:(UIViewController *)disappearViewController appearViewController:(UIViewController *)appearViewController {

    if (![self.delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {

//        BOOL shouldCustomNavigationBarTransition = [self shouldCustomTransitionAutomaticallyWithFirstViewController:disappearViewController secondViewController:appearViewController];
//
//        if (shouldCustomNavigationBarTransition) {
            [disappearViewController addTransitionNavigationBarIfNeeded];
            if (appearViewController.transitionNavigationBar) {
                // 假设从A→B→C，其中A设置了bar的样式，B跟随A所以B里没有设置bar样式的代码，C又把样式改为另一种，此时从C返回B时，由于B没有设置bar的样式的代码，所以bar的样式依然会保留C的，这就错了，所以每次都要手动改回来才保险
                [UIViewController replaceStyleForNavigationBar:appearViewController.transitionNavigationBar withNavigationBar:self.navigationBar];
//            }
            disappearViewController.prefersNavigationBarBackgroundViewHidden = YES;
        }

    }
}

@end
