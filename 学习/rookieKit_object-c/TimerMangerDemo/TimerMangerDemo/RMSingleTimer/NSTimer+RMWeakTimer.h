//
//  NSTimer+RMWeakTimer.h
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/16.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (RMWeakTimer)
+ (NSTimer *)rm_timerWithTimeInterval:(NSTimeInterval)interval
                               target:(id)aTarget
                             selector:(SEL)aSelector
                             userInfo:(id)userInfo
                              repeats:(BOOL)repeats;
@end

NS_ASSUME_NONNULL_END
