//
//  UINavigationBar+RMNavigation.m
//  RMNavigation
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UINavigationBar+RMNavigation.h"
#import <objc/runtime.h>
#define rm_setBarTintColorKey @"rm_setBarTintColor"

@implementation UINavigationBar (RMNavigation)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换方法
        [self exchangeMethod:@selector(setBarTintColor:)
            swizzledSelector:@selector(rm_setBarTintColor:)];
    });
}

+ (void)exchangeMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod  = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod  = class_getInstanceMethod([self class], swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)rm_setBarTintColor:(UIColor *)barTintColor {
    [self rm_setBarTintColor:barTintColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:rm_setBarTintColorKey object:barTintColor];
}





@end
