//
//  RMSingleTimerModel.h
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/8.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RMSingleTimerModel : NSObject
// 监听对象
//@property (nonatomic, weak) NSObject *observer;
// timer
@property (nonatomic, weak) NSTimer *timer;
//// 响应方法
//@property (nonatomic, assign) SEL action;
//// 计时器时间间隔
//@property (nonatomic, assign) double timeInterval;
//// 响应方法执行队列
//@property (nonatomic, strong) dispatch_queue_t queue;
// 监听事件key
@property (nonatomic, strong) NSString *name;
//// 计时器数字记录
//@property (nonatomic, assign) double currentTime;
//// 执行次数
//@property (nonatomic, assign) NSInteger repeatTime;
@end

NS_ASSUME_NONNULL_END
