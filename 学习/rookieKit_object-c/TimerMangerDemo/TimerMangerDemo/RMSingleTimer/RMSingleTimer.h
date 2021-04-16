//
//  RMSingleTimer.h
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/8.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RMSingleTimer : NSObject

/** 计时器精确度(暂不支持自定义精度) */

//@property (nonatomic, assign, readonly) double timerPrecision;

/**
 获取单例计时器对象

 @return 单例计时器对象
 */
+ (instancetype)shareInstance;

/**
 添加一个监听事件

 @param observer     监听者
 @param name         监听事件
 @param timeInterval 响应时间间隔
 @param action       响应方法
 */
- (void)addObserver:(NSObject *)observer name:(NSString *)name timeInterval:(CGFloat)timeInterval action:(SEL)action;

/**
 是否包含某个监听事件

 @param observer 监听者
 @param name     监听事件
 @return         是否包含
 */
- (BOOL)containsObserver:(NSObject *)observer name:(NSString *)name;

/**
 移除某一个方法监听

 @param observer 监听者
 @param name     监听事件名
 */
- (void)removeObserver:(NSObject *)observer name:(NSString *)name;

/**
 移除某一个监听者所有监听事件

 @param observer 监听者
 */
- (void)removeObserver:(NSObject *)observer;

/**
 终止计时器事件，并移除常驻线程
 */
- (void)stop;
@end

NS_ASSUME_NONNULL_END
