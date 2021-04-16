//
//  UINavigationBar+RMTransition.m
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UINavigationBar+RMTransition.h"
#import "RMRuntime.h"
@implementation UINavigationBar (RMTransition)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(setShadowImage:) newSelector:@selector(NavigationBarTransition_setShadowImage:)];
        
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(setBarTintColor:) newSelector:@selector(NavigationBarTransition_setBarTintColor:)];
        [RMRuntime rm_exchangeInstanceMethod:class originSelector:@selector(setBackgroundImage:forBarMetrics:) newSelector:@selector(NavigationBarTransition_setBackgroundImage:forBarMetrics:)];
    });
}

- (void)NavigationBarTransition_setShadowImage:(UIImage *)image {
    [self NavigationBarTransition_setShadowImage:image];
    if (self.rm_transitionNavigationBar) {
        self.rm_transitionNavigationBar.shadowImage = image;
    }
}


- (void)NavigationBarTransition_setBarTintColor:(UIColor *)tintColor {
    [self NavigationBarTransition_setBarTintColor:tintColor];
    if (self.rm_transitionNavigationBar) {
        self.rm_transitionNavigationBar.barTintColor = self.barTintColor;
    }
}

- (void)NavigationBarTransition_setBackgroundImage:(UIImage *)backgroundImage forBarMetrics:(UIBarMetrics)barMetrics {
    [self NavigationBarTransition_setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    if (self.rm_transitionNavigationBar) {
        [self.rm_transitionNavigationBar setBackgroundImage:backgroundImage forBarMetrics:barMetrics];
    }
}

static char transitionNavigationBarKey;

- (UINavigationBar *)rm_transitionNavigationBar {
    return objc_getAssociatedObject(self, &transitionNavigationBarKey);
}

- (void)setRm_transitionNavigationBar:(UINavigationBar *)rm_transitionNavigationBar {
    objc_setAssociatedObject(self, &transitionNavigationBarKey, rm_transitionNavigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
