//
//  UIView+RMView.m
//  RMDrawTool
//
//  Created by Rookieme on 2018/12/20.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "UIView+RMView.h"
#import <objc/runtime.h>
#import "RMDrawTool.h"
#import "RMDrawView.h"
#import "RMDrawButton.h"
@implementation UIView (RMView)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalSelector = @selector(hitTest:withEvent:);
        SEL swizzledSelector = @selector(rm_hitTest:withEvent:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL success = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
        if (success) {
            class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (BOOL)rm_isParentView {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setRm_isParentView:(BOOL)rm_isParentView {
    objc_setAssociatedObject(self, @selector(rm_isParentView), @(rm_isParentView), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)rm_hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    UIView *view = [self rm_hitTest:point withEvent:event];
    
    if (self.rm_isParentView) {
        //系统默认会忽略isUserInteractionEnabled设置为NO、隐藏、alpha小于等于0.01的视图
        if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) return nil;
        
        if ([self pointInside:point withEvent:event]) {
            
            NSMutableArray *tempArray = [NSMutableArray new];
            
            for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
                
                CGPoint convertedPoint = [subview convertPoint:point fromView:self];
                UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
                
                if (hitTestView) {
                    
                    if ([hitTestView isKindOfClass:[RMDrawButton class]]) return hitTestView;
                    
                    if ([hitTestView isKindOfClass:[RMDrawView class]]) {
                        [tempArray addObject:hitTestView];
                    } else {
                        if (tempArray.count == 0) return hitTestView;
                    }
                }
            }
            
            if (tempArray.count > 0) {
                RMDrawView *view = [self findAllSPDrawViewWithArrays:tempArray];
                [tempArray removeAllObjects];
                tempArray = nil;
                return view;
            }
            
            return self;
        }
        
        return nil;
    }
    
    return view;
}

- (RMDrawView *)findAllSPDrawViewWithArrays:(NSArray *)views
{
    NSMutableArray *lines = [NSMutableArray new];
    NSMutableArray *faces = [NSMutableArray new];
    
    
    for (RMDrawView *view in views) {
        if (view.type == RMDrawToolTypeLine) [lines addObject:view];
        
        if (view.type == RMDrawToolTypeCircle || view.type == RMDrawToolTypeFace) {
            [faces addObject:view];
        }
        
    }
    
    if (lines.count > 0) return lines[0];
    
    if (faces.count > 0) return [self filterSizeMost:faces];
    
    return views[0];
}

- (RMDrawView *)filterSizeMost:(NSArray *)views
{
    __block RMDrawView *returnView;
    __block double area = 0.0;
    [views enumerateObjectsUsingBlock:^(RMDrawView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        double tempArea = view.frame.size.width * view.frame.size.height;
        if (idx == 0) {
            area = tempArea;
            returnView = view;
        }
        
        if (area > tempArea) returnView = view;
    }];
    return returnView;
}


@end
