//
//  RMTimerManger.h
//  RMTimerManger
//
//  Created by Rookieme on 2019/4/19.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 计时器管理者
 1、解决timer和监听对象 循环引用问题（不必关注计时器释放）
 2、开启常驻线程，添加计时器，尽量保证计时器精确性
 3、方便管路计时器，可销毁所有计时器、销毁与监听对象相关计时器、销毁单个计时器
 */
@interface RMTimerManger : NSObject


/**
 计时器map（第一层字典key对应监听对象 hash属性）

 @return 计时器map
 */
+ (NSDictionary *)timerMap;

/**
 添加计时器(默认循环调用)
 
 @param name         监听事件key
 @param timeInterval 时间间隔
 @param target       监听对象
 @param selector     响应方法
 */
+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector;


/**
 倒计时计时器（只执行一次）

 @param name         监听事件key
 @param timeInterval 时间间隔
 @param target       监听对象
 @param selector     响应方法
 */
+ (void)countdownTimerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector;

/**
 添加计时器

 @param name         监听事件key
 @param timeInterval 时间间隔
 @param target       监听对象
 @param selector     响应方法
 @param userInfo     用户信息
 @param repeats      是否循环调用
 */
+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats;

/**
 添加计时器
 
 @param name         监听事件key
 @param timeInterval 时间间隔
 @param target       监听对象
 @param selector     响应方法
 @param userInfo     用户信息
 @param repeats      是否循环调用
 @param runLoopMode  运行循环模式
 */
+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats runLoopMode:(NSRunLoopMode)runLoopMode;


/**
 添加计时器

 @param name         监听事件key
 @param timeInterval 时间间隔
 @param target       监听对象
 @param selector     响应方法
 @param userInfo     用户信息
 @param repeats      是否循环调用
 @param runLoopMode  运行循环模式
 @param isFire       是否立即执行
 */
+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats runLoopMode:(NSRunLoopMode)runLoopMode isFire:(BOOL)isFire;

/**
 暂停某个计时器

 @param target 监听对象
 @param name   监听事件key
 */
+ (void)pauseByTarget:(NSObject *)target name:(NSString *)name;

/**
 暂停监听对象所有计时器

 @param target 监听对象
 */
+ (void)pauseByTarget:(NSObject *)target;

/**
 恢复某个所有计时器
 
 @param target 监听对象
 @param name   监听事件key
 */
+ (void)reuseByTarget:(NSObject *)target name:(NSString *)name;

/**
 恢复监听对象所有计时器
 
 @param target 监听对象
 */
+ (void)reuseByTarget:(NSObject *)target;

/**
 销毁某个计时器
 
 @param target  监听对象
 @param name    监听事件key
 */
+ (void)invalidateByTarget:(NSObject *)target name:(NSString *)name;

/**
 销毁监听对象所有计时器
 
 @param target 监听对象
 */
+ (void)invalidateByTarget:(NSObject *)target;

/**
 销毁所有计时器
 */
+ (void)invalidate;


/**
 是否存在计时器
 
 @param target 监听对象
 @param name   监听事件key
 @return       是否存在
 */
+ (BOOL)isExistTimerByTarget:(NSObject *)target name:(NSString *)name;

#pragma mark -
#pragma mark - TODO
//+ (void)runLoopModeTransform:(NSRunLoopMode)runLoopMode target:(NSObject *)target name:(NSString *)name;
//+ (void)threadTransform:(NSThread *)thread target:(NSObject *)target name:(NSString *)name;
//+ (void)threadTransform:(NSThread *)thread runLoopMode:(NSRunLoopMode)runLoopMode target:(NSObject *)target name:(NSString *)name;


@end

NS_ASSUME_NONNULL_END
