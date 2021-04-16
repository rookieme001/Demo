//
//  UINavigationBar+RM.m
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UINavigationBar+RM.h"

@implementation UINavigationBar (RM)
- (UIView *)rm_backgroundView {
    return [self valueForKey:@"_backgroundView"];
}

- (__kindof UIView *)rm_backgroundContentView {
    if (@available(iOS 10, *)) {
        UIImageView *imageView = [self.rm_backgroundView valueForKey:@"_backgroundImageView"];
        UIVisualEffectView *visualEffectView = [self.rm_backgroundView valueForKey:@"_backgroundEffectView"];
        UIView *customView = [self.rm_backgroundView valueForKey:@"_customBackgroundView"];
        UIView *result = customView && customView.superview ? customView : (imageView && imageView.superview ? imageView : visualEffectView);
        return result;
    } else {
        UIView *backdrop = [self.rm_backgroundView valueForKey:@"_adaptiveBackdrop"];
        UIView *result = backdrop && backdrop.superview ? backdrop : self.rm_backgroundView;
        return result;
    }
}

- (UIImageView *)rm_shadowImageView {
    // UINavigationBar 在 init 完就可以获取到 backgroundView 和 shadowView，无需关心调用时机的问题
    return [self.rm_backgroundView valueForKey:@"_shadowView"];
}
@end
