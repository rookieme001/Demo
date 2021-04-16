//
//  RMDrawView.m
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/19.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import "RMDrawView.h"

@interface RMDrawView ()
{
    //拖动的起始坐标点
    CGPoint _touchPoint;
    //起始按钮的x,y值
    CGFloat _touchBtnX;
    CGFloat _touchBtnY;
}
@end

@implementation RMDrawView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        
        BOOL isResponse = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(rm_drawViewIsResponsePoint:)]) {
            isResponse = [self.delegate rm_drawViewIsResponsePoint:point];
        }
        if (isResponse == NO) {
            return nil;
        }
        return self;
    }
    return nil;
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [super touchesBegan:touches withEvent:event];
    
    if (!_rm_allowMove) return;
    
    
    //按钮刚按下的时候，获取此时的起始坐标
    UITouch *touch = [touches anyObject];
    _touchPoint = [touch locationInView:self];
    
    _touchBtnX = self.frame.origin.x;
    _touchBtnY = self.frame.origin.y;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rm_drawViewMoveEvent)]) {
        [self.delegate rm_drawViewMoveEvent];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    if (!_rm_allowMove) {
        [super touchesMoved:touches withEvent:event];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    CGPoint currentPosition = [touch locationInView:self];
    
    //偏移量(当前坐标 - 起始坐标 = 偏移量)
    CGFloat offsetX = currentPosition.x - _touchPoint.x;
    CGFloat offsetY = currentPosition.y - _touchPoint.y;
    
    //移动后的按钮中心坐标
    CGFloat centerX = self.center.x + offsetX;
    CGFloat centerY = self.center.y + offsetY;
    self.center = CGPointMake(centerX, centerY);

    if (self.delegate && [self.delegate respondsToSelector:@selector(rm_drawViewMoveEvent)]) {
        [self.delegate rm_drawViewMoveEvent];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!_rm_allowMove) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    CGFloat btnY = self.frame.origin.y;
    CGFloat btnX = self.frame.origin.x;
    
    CGFloat minDistance = 2;
    
    //结束move的时候，计算移动的距离是>最低要求，如果没有，就调用按钮点击事件
    BOOL isOverX = fabs(btnX - _touchBtnX) > minDistance;
    BOOL isOverY = fabs(btnY - _touchBtnY) > minDistance;

    if (isOverX || isOverY) {
        //超过移动范围就不响应点击 - 只做移动操作
        [self touchesCancelled:touches withEvent:event];
    }else{
        [super touchesEnded:touches withEvent:event];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(rm_drawViewMoveEvent)]) {
        [self.delegate rm_drawViewMoveEvent];
    }
}

@end
