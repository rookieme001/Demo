//
//  RMTimerManger.m
//  RMTimerManger
//
//  Created by Rookieme on 2019/4/19.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "RMTimerManger.h"
#import "RMTimerModel.h"
#import <objc/runtime.h>

/** 去警告⚠️ */
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define Lock_lock [[RMTimerManger shareInstance].operationLock unlock];
#define Lock_unlock [[RMTimerManger shareInstance].operationLock unlock];

@interface RMTimerManger ()
/** @{targetHashkey:@{name:model},targetHashkey:@{name:model}} */
@property (nonatomic, strong) NSMutableDictionary *modelMap;
/** 🔐保证线程安全 */
@property (nonatomic, strong) NSLock            *operationLock;
@end

@implementation RMTimerManger
#pragma mark
#pragma mark 单例模式
static RMTimerManger *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

+ (instancetype)shareInstance {
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

-(id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}
#pragma mark -
#pragma mark - 常驻线程
static NSThread *thread = nil;
// 标记是否要继续事件循环
static BOOL runAlways = YES;
+ (NSThread *)threadForDispatch {
    if (thread == nil) {
        @synchronized(self) {
            if (thread == nil) {
                // 线程的创建
                thread = [[NSThread alloc] initWithTarget:self selector:@selector(runRequest) object:nil];
                [thread setName:@"cn.rmtimermanger.thread"];
                //启动
                [thread start];
            }
        }
    }
    return thread;
}

+ (void)runRequest {
    // 创建一个Source
    CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
    CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    // 创建RunLoop，同时向RunLoop的DefaultMode下面添加Source
    CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    // 如果可以运行
    while (runAlways) {
        @autoreleasepool {
            // 令当前RunLoop运行在DefaultMode下面
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, true);
        }
    }
    // 某一时机 静态变量runAlways = NO时 可以保证跳出RunLoop，线程退出
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
    CFRelease(source);
}

#pragma mark -
#pragma mark - 计时器创建
+ (NSTimer *)creatTimerWithTimeInterval:(NSTimeInterval)timeInterval userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo runLoopMode:(NSRunLoopMode)runLoopMode {
    NSTimer *timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(fire:) userInfo:userInfo repeats:yesOrNo];
    // 子线程添加计时器
    [self performSelector:@selector(addTimerToSubthread:) onThread:[NSThread mainThread] withObject:@{@"timer":timer,@"runloopmMode":runLoopMode} waitUntilDone:NO];
    return timer;
}

+ (void)addTimerToSubthread:(NSDictionary *)userInfo {
    [[NSRunLoop currentRunLoop] addTimer:userInfo[@"timer"] forMode:userInfo[@"runloopmMode"]];
}

+ (void)fire:(NSTimer *)timer {
    // 获取关联对象
    RMTimerModel *model = objc_getAssociatedObject(self, (__bridge const void * _Nonnull)(timer));
    if (model && model.target) {
        SuppressPerformSelectorLeakWarning([model.target performSelector:model.selector withObject:timer];);
    } else {
        // 当监听对象被释放，移除监听对象map
        [self invalidateByTarget:nil orHashkey:model.hashKey];
        // 释放关联对象，关联对象nil系统底层 会将 ASSOCIATIONMAP中其对象 释放
        objc_setAssociatedObject(self, &timer, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/** 销毁计时器，移除监听对象 */
+ (void)invalidateTimerByModel:(RMTimerModel *)model {
    if (model == nil || model.timer == nil) return ;
    
    [model.timer invalidate];
    model.timer  = nil;
    model.target = nil;
}

#pragma mark -
#pragma mark - 抽象API
+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector {
    [self timerWithName:name timeInterval:timeInterval target:target selector:selector userInfo:nil repeats:YES runLoopMode:NSRunLoopCommonModes];
}

+ (void)countdownTimerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector {
     [self timerWithName:name timeInterval:timeInterval target:target selector:selector userInfo:nil repeats:NO runLoopMode:NSRunLoopCommonModes isFire:NO];
}

+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats {
    [self timerWithName:name timeInterval:timeInterval target:target selector:selector userInfo:userInfo repeats:repeats runLoopMode:NSRunLoopCommonModes];
}

+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats runLoopMode:(NSRunLoopMode)runLoopMode {
    [self timerWithName:name timeInterval:timeInterval target:target selector:selector userInfo:userInfo repeats:repeats runLoopMode:NSRunLoopCommonModes isFire:YES];
}

+ (void)timerWithName:(NSString *)name timeInterval:(NSTimeInterval)timeInterval target:(NSObject *)target selector:(SEL)selector userInfo:(nullable id)userInfo repeats:(BOOL)repeats runLoopMode:(NSRunLoopMode)runLoopMode isFire:(BOOL)isFire {
    // 前置条件判断
    if (timeInterval <= 0 || name == nil || target == nil || selector == nil || ![target respondsToSelector:selector] || [name isEqualToString:@""]) return ;
    
    // 配置运行循环mode
    NSRunLoopMode tempMode = runLoopMode;
    if (runLoopMode == nil) tempMode = NSRunLoopCommonModes;
    
    // 创建计时器
    NSTimer *timer = [self creatTimerWithTimeInterval:timeInterval userInfo:userInfo repeats:repeats runLoopMode:tempMode];
    
    // 创建模型
    RMTimerModel *model = [RMTimerModel new];
    // 设置属性
    [model setTimer:timer];
    [model setTarget:target];
    [model setName:name];
    [model setSelector:selector];
    [model setHashKey:target.hash];
    
    // 往map添加模型
    [self addModelToMap:model isFire:isFire];
}

+ (void)addModelToMap:(RMTimerModel *)model isFire:(BOOL)isFire{
    Lock_lock
    if (![RMTimerManger shareInstance].modelMap) {
        [self initOperation];
    }
    
    // 查找旧计时器model
    RMTimerModel *oldModel = [self findModellnMap:model.target.hash name:model.name];
    //  存在旧计时器model，则移除旧计时器和旧计时器model
    if (oldModel) [self invalidateTimerByModel:oldModel];
    
    // 添加新的model
    NSMutableDictionary *targetDictionary = [[RMTimerManger shareInstance].modelMap objectForKey:@(model.target.hash)];
    if (!targetDictionary) {
        targetDictionary = [NSMutableDictionary new];
        [[RMTimerManger shareInstance].modelMap setObject:targetDictionary forKey:@(model.target.hash)];
    }
    [targetDictionary setObject:model forKey:model.name];
    
    // 添加动态绑定
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(model.timer), model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (isFire) {
        [model.timer fire];
    }
    
    Lock_unlock
}

+ (void)invalidateByTarget:(NSObject *)target name:(NSString *)name {
    Lock_lock
    if (!target) {
        Lock_unlock
        return ;
    }
    // 查找计时器model，存在则移除
    RMTimerModel *model = [self findModellnMap:target.hash name:name];
    if (model) {
        NSMutableDictionary *targetDictionary = [[RMTimerManger shareInstance].modelMap objectForKey:@(target.hash)];
        [targetDictionary removeObjectForKey:name];
        [self invalidateTimerByModel:model];
    }
    Lock_unlock
}

+ (void)invalidateByTarget:(NSObject *)target {
    [self invalidateByTarget:target orHashkey:0];
}

+ (void)invalidate {
    Lock_lock
    if (![RMTimerManger shareInstance].modelMap) {
        Lock_unlock
        return ;
    }
    
    for (NSMutableDictionary *targetDictionary in [RMTimerManger shareInstance].modelMap.allValues) {
        for (RMTimerModel *model  in targetDictionary.allValues) {
            [self invalidateTimerByModel:model];
        }
    }
    // 清空map
    [[RMTimerManger shareInstance].modelMap removeAllObjects];
    [RMTimerManger shareInstance].modelMap = nil;
    Lock_unlock
}

+ (void)pauseByTarget:(NSObject *)target name:(NSString *)name {
    Lock_lock
    if (!target) {
        Lock_unlock
        return ;
    }
    // 查找计时器model，存在则移除
    RMTimerModel *model = [self findModellnMap:target.hash name:name];
    if (model && model.timer) {
        [model.timer setFireDate:[NSDate distantFuture]];
    }
    Lock_unlock
}

+ (void)pauseByTarget:(NSObject *)target {
    Lock_lock
    if (!target) {
        Lock_unlock
        return ;
    }
    
    // 获取hashkey
    NSUInteger tempHashKey = target.hash;
    
    // 查找监听对象map
    NSMutableDictionary *targetDictionary = [self findObjectInMap:tempHashKey];
    
    // 如果监听对象map为空，返回
    if (!targetDictionary) {
        Lock_unlock
        return ;
    }
    
    // 销毁计时器
    for (RMTimerModel *model in targetDictionary.allValues)
    {
        if (model.timer) [model.timer setFireDate:[NSDate distantFuture]];
    }
    
    Lock_unlock
}

+ (void)reuseByTarget:(NSObject *)target name:(NSString *)name {
    Lock_lock
    if (!target) {
        Lock_unlock
        return ;
    }
    // 查找计时器model，存在则移除
    RMTimerModel *model = [self findModellnMap:target.hash name:name];
    if (model && model.timer) {
        [model.timer setFireDate:[NSDate distantPast]];
    }
    Lock_unlock
}

+ (void)reuseByTarget:(NSObject *)target {
    Lock_lock
    if (!target) {
        Lock_unlock
        return ;
    }
    
    // 获取hashkey
    NSUInteger tempHashKey = target.hash;
    
    // 查找监听对象map
    NSMutableDictionary *targetDictionary = [self findObjectInMap:tempHashKey];
    
    // 如果监听对象map为空，返回
    if (!targetDictionary) {
        Lock_unlock
        return ;
    }
    
    // 销毁计时器
    for (RMTimerModel *model in targetDictionary.allValues)
    {
        if (model.timer) [model.timer setFireDate:[NSDate distantPast]];
    }
    
    Lock_unlock
}

+ (NSDictionary *)timerMap {
    Lock_lock
    NSMutableDictionary *tempModeMap = [NSMutableDictionary new];
    if ([RMTimerManger shareInstance].modelMap) {
        tempModeMap =  [[RMTimerManger shareInstance].modelMap copy];
    }
    
    NSMutableDictionary *tempCacheMap = [NSMutableDictionary new];
    [tempModeMap enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableDictionary *dict, BOOL * _Nonnull stop) {
        NSMutableDictionary *timerCache = [NSMutableDictionary new];
        for (RMTimerModel *model in dict.allValues) {
            NSMutableDictionary *timer = [NSMutableDictionary new]; 
            [timer setObject:model.name   forKey:@"name"];
            [timer setObject:model.target forKey:@"target"];
            [timerCache setObject:timer  forKey:model.name];
        }
        [tempCacheMap setObject:timerCache forKey:key];
    }];
    
    Lock_unlock
    return tempCacheMap;
}

+ (BOOL)isExistTimerByTarget:(NSObject *)target name:(NSString *)name {
    Lock_lock
    if (!target) {
        Lock_unlock
        return NO;
    }
    // 查找计时器model，存在则移除
    RMTimerModel *model = [self findModellnMap:target.hash name:name];
    if (model && model.timer) {
        Lock_unlock
        return YES;
    }
    Lock_unlock
    return NO;
}

#pragma mark -
#pragma mark - 私有方法
/** 常驻线程和map初始化 */
+ (void)initOperation {
    [RMTimerManger shareInstance].modelMap = [NSMutableDictionary new];
    [RMTimerManger threadForDispatch];
    runAlways = YES;
}

/** 移除监听对象map */
+ (void)invalidateByTarget:(NSObject *)target orHashkey:(NSUInteger)hashKey{
    Lock_lock
    if (!target && !hashKey) {
        Lock_unlock
        return ;
    }
    
    // 获取hashkey,优先target
    NSUInteger tempHashKey = hashKey;
    if (target) tempHashKey = target.hash;
    
    // 查找监听对象map
    NSMutableDictionary *targetDictionary = [self findObjectInMap:tempHashKey];
    
    // 如果监听对象map为空，返回
    if (!targetDictionary) {
        Lock_unlock
        return ;
    }
    
    // 销毁计时器
    for (RMTimerModel *model in targetDictionary.allValues) {
        [self invalidateTimerByModel:model];
    }
    
    // 移除监听对象map
    [[RMTimerManger shareInstance].modelMap removeObjectForKey:@(tempHashKey)];
    Lock_unlock
}


/** 查找model */
+ (RMTimerModel *)findModellnMap:(NSUInteger)hashKey name:(NSString *)name {
    // 查找监听对象map
    NSMutableDictionary *targetDictionary = [self findObjectInMap:hashKey];
    //  未找到监听对象map返回nil
    if (!targetDictionary) return nil;
    //  返回model
    RMTimerModel *model = [targetDictionary objectForKey:name];
    return model;
}

/** 查找监听对象map */
+ (NSMutableDictionary *)findObjectInMap:(NSUInteger)hashKey {
    // 如果map为空，返回nil
    if (![RMTimerManger shareInstance].modelMap) return nil;
    // 如果监听对象map为空，返回nil
    NSMutableDictionary *targetDictionary = [[RMTimerManger shareInstance].modelMap objectForKey:@(hashKey)];
    if (!targetDictionary) return nil;
    //  找到返回监听对象map
    return targetDictionary;
}


@end
