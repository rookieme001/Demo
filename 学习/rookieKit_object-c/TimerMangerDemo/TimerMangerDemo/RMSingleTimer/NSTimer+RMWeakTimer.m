//
//  NSTimer+RMWeakTimer.m
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/16.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "NSTimer+RMWeakTimer.h"
@interface RMTimerWeakObject : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;

- (void)fire:(NSTimer *)timer;

@end

@implementation RMTimerWeakObject

- (void)fire:(NSTimer *)timer
{
    if (self.target) {
        if ([self.target respondsToSelector:self.selector]) {
            [self.target performSelector:self.selector withObject:timer.userInfo];
        }
    }
    else{
        [self.timer invalidate];
    }
}

@end

@implementation NSTimer (RMWeakTimer)
+ (NSTimer *)rm_timerWithTimeInterval:(NSTimeInterval)interval
                               target:(id)aTarget
                             selector:(SEL)aSelector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats
{
    RMTimerWeakObject *object = [[RMTimerWeakObject alloc] init];
    object.target   = aTarget;
    object.selector = aSelector;
    object.timer    = [NSTimer scheduledTimerWithTimeInterval:interval target:object selector:@selector(fire:) userInfo:userInfo repeats:repeats];
    return object.timer;
}
@end
