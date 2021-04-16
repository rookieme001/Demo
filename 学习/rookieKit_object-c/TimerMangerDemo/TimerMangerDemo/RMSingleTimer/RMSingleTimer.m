//
//  RMSingleTimer.m
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/8.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "RMSingleTimer.h"
#import "RMSingleTimerModel.h"
#import "NSTimer+RMWeakTimer.h"
/** 去警告⚠️ */
#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface RMSingleTimer ()
@property (nonatomic, strong) NSMutableDictionary *items;
//@property (nonatomic, strong) NSTimer *singleTimer;
@property (nonatomic, strong) NSLock  *singleLock;

//@property (nonatomic, assign) double singleTimerRatio;
@end

@implementation RMSingleTimer
#pragma mark -
#pragma mark - 单例模式
static RMSingleTimer *_instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            [_instance initOperation];
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
                [thread setName:@"cn.rmsingletimer.thread"];
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

/** 常驻线程退出 */
- (void)exitThread {
    runAlways       = NO;
    thread         = nil;
}

#pragma mark -
#pragma mark - 初始化计时器、锁、执行线程
- (void)initOperation {
    _items           = [NSMutableDictionary new];
    _singleLock       = [[NSLock alloc] init];
}

- (void)addTimerToSubThread:(NSTimer *)timer {
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

#pragma mark -
#pragma mark - 监听者被销毁移除策略 (定时移除 OR 高频触发)
/** 高频触发测移除 */
- (void)highFrequencyTriggerDestoryNullObserver {
    [self checkObserverDestoryed];
}

#pragma mark -
#pragma mark - 计时器监听者销毁检测
- (void)checkObserverDestoryed {
    if (self.items.allValues.count > 0) {
        // 读取监听者事件字典缓存
        NSDictionary *tempItems = [self.items copy];
        // 即将缓存监听者置空 元素key数组
        NSMutableArray *keys = [NSMutableArray new];
        // 遍历监听者事件缓存，找出被销毁的元素
        [tempItems enumerateKeysAndObjectsUsingBlock:^(NSString *keyName, NSMutableDictionary *mutableDict, BOOL * _Nonnull stop) {
            if (mutableDict.allValues.count == 0) {
                [keys addObject:keyName];
            } else {
                RMSingleTimerModel *model = [mutableDict.allValues firstObject];
                if (!model.timer) [keys addObject:keyName];
            }
        }];
        // 获取监听者为空的 key值数组并销毁
        if (keys.count) [self.items removeObjectsForKeys:keys];
    }
}

#pragma mark -
#pragma mark - 抽象API
/** 添加一个监听事件 */
- (void)addObserver:(NSObject *)observer name:(NSString *)name timeInterval:(CGFloat)timeInterval action:(SEL)action{
    [self removeObserver:observer name:name];
    [_singleLock lock];
    [self highFrequencyTriggerDestoryNullObserver];
    // 高频触发检测计时器是否启动
    NSTimer *timer = [NSTimer rm_timerWithTimeInterval:timeInterval target:observer selector:action userInfo:[NSDictionary new] repeats:YES];
    [self addTimerToSubThread:timer];
    
    RMSingleTimerModel *model = [RMSingleTimerModel new];
    [model setTimer:timer];
    [model setName:name];
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *hashKey = [NSString stringWithFormat:@"%ld",observer.hash];
    // 判断是否缓存有监听者计时器缓存map，有则获取,无则添加
    if ([_items valueForKey:hashKey]) {
        dict = [_items valueForKey:hashKey];
    } else {
        [_items setObject:dict forKey:hashKey];
    }
    // 赋值：监听者计时器缓存map下，有则覆盖，无则添加
    [dict setObject:model forKey:name];
    [_singleLock unlock];
    
    
}

- (BOOL)containsObserver:(NSObject *)observer name:(NSString *)name {
    [_singleLock lock];
    BOOL isContain = NO;
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *hashKey = [NSString stringWithFormat:@"%ld",observer.hash];
    if ([_items valueForKey:hashKey]) {
        dict = [_items valueForKey:hashKey];
    } else {
        goto nextStep;
    }
    
    if ([dict valueForKey:name]) {
        isContain = YES;
        goto nextStep;
    } else {
        goto nextStep;
    }
    
nextStep:
    [_singleLock unlock];
    return isContain;
}

/** 移除某一个方法监听 */
- (void)removeObserver:(NSObject *)observer name:(NSString *)name {
    [_singleLock lock];
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSString *hashKey = [NSString stringWithFormat:@"%ld",observer.hash];
    if ([_items valueForKey:hashKey]) {
        dict = [_items valueForKey:hashKey];
    }
    
    RMSingleTimerModel *model = [dict objectForKey:name];
    if (model) {
        [self stopTimerByModel:model];
        [dict removeObjectForKey:name];
    }
    [_singleLock unlock];
}

/** 移除某一个监听者所有监听事件 */
- (void)removeObserver:(NSObject *)observer {
    [_singleLock lock];
    NSString *hashKey = [NSString stringWithFormat:@"%ld",observer.hash];
    NSMutableDictionary *dict = [_items valueForKey:hashKey];
    if (dict) {
        for (RMSingleTimerModel *model in dict.allValues) {
            [self stopTimerByModel:model];
        }
        [_items removeObjectForKey:hashKey];
    }
    
    [_singleLock unlock];
}

/** 终止计时器事件 */
- (void)stop {
    [self.singleLock lock];
    
    for (NSMutableDictionary *dict in self.items.allValues) {
        for (RMSingleTimerModel *model in dict.allValues) {
            [self stopTimerByModel:model];
        }
    }
    
    [self.items removeAllObjects];
    [self.singleLock unlock];
}

- (void)stopTimerByModel:(RMSingleTimerModel *)model {
    [model.timer invalidate];
    model.timer = nil;
}


@end
