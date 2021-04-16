//
//  UIViewController+RM.m
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UIViewController+RM.h"
#import "RMRuntime.h"
@implementation UIViewController (RM)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            @selector(viewDidLoad),
            @selector(viewWillAppear:),
            @selector(viewDidAppear:),
            @selector(viewWillDisappear:),
            @selector(viewDidDisappear:)
        };
        
        for (NSUInteger index = 0; index < sizeof(selectors) / sizeof(SEL); index++) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"rm_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            [RMRuntime rm_exchangeInstanceMethod:[self class] originSelector:originalSelector newSelector:swizzledSelector];
        }
    });
}

- (void)rm_viewDidLoad {
    [self rm_viewDidLoad];
}

- (void)rm_viewWillAppear:(BOOL)animated {
    [self rm_viewWillAppear:animated];
}

- (void)rm_viewDidAppear:(BOOL)animated {
    [self rm_viewDidAppear:animated];
}

- (void)rm_viewWillDisappear:(BOOL)animated {
    [self rm_viewWillDisappear:animated];
}

- (void)rm_viewDidDisappear:(BOOL)animated {
    [self rm_viewDidDisappear:animated];
}

@end
