//
//  RMTimerModel.h
//  RMTimerManger
//
//  Created by Rookieme on 2019/4/19.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMTimerModel : NSObject
// 监听对象
@property (nonatomic, weak)   NSObject *target;
// 计时器
@property (nonatomic, weak)   NSTimer  *timer;
// 监听事件key
@property (nonatomic, copy)   NSString *name;
// 响应方法
@property (nonatomic, assign) SEL selector;
// 监听对象hash
@property (nonatomic, assign) NSUInteger hashKey;
@end

NS_ASSUME_NONNULL_END
