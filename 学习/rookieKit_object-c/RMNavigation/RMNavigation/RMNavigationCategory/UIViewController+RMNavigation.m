//
//  UIViewController+RMNavigation.m
//  RMNavigation
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UIViewController+RMNavigation.h"
#import <objc/runtime.h>

#define rm_willMoveToParentViewKey @"rm_willMoveToParentViewController"
#define rm_didMoveToParentViewKey @"rm_didMoveToParentViewController"


@implementation UIViewController (RMNavigation)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换方法
        [self exchangeMethod:@selector(willMoveToParentViewController:)
            swizzledSelector:@selector(rm_willMoveToParentViewController:)];
        
        [self exchangeMethod:@selector(didMoveToParentViewController:)
            swizzledSelector:@selector(rm_didMoveToParentViewController:)];
    });
}

+ (void)exchangeMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod  = class_getInstanceMethod([self class], originalSelector);
    Method swizzledMethod  = class_getInstanceMethod([self class], swizzledSelector);
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void)rm_willMoveToParentViewController:(UIViewController *)parent {
    [self rm_willMoveToParentViewController:parent];
    [[NSNotificationCenter defaultCenter] postNotificationName:rm_willMoveToParentViewKey object:nil];
    
}

- (void)rm_didMoveToParentViewController:(UIViewController *)parent {
    [self rm_didMoveToParentViewController:parent];
    [[NSNotificationCenter defaultCenter] postNotificationName:rm_didMoveToParentViewKey object:nil];
    
}

@end
