//
//  RMCacheOperationManger.m
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMCacheOperationManger.h"
#import "NSObject+RMNetwork.h"
#import "RMCacheOperationModel.h"
@implementation RMCacheOperationManger

static NSMutableArray      *_cacheArrar;
static dispatch_semaphore_t semaphoreLock;
static dispatch_queue_t     queue;

/** 拼接完整url */
+ (NSString *)urlAbsolutiongWithUrlStr:(NSString *)urlStr params:(NSDictionary *)params {
    NSURL *url = [NSURL URLWithString:urlStr relativeToURL:[NSURL URLWithString:urlStr]];
    urlStr = url.absoluteString;
    NSMutableArray *arr = [NSMutableArray new];
    for(NSString *key in [params allKeys]){
        NSString *str = [key stringByAppendingFormat:@"=%@",[params[key] rm_isNotEmpty]?params[key]:@""];
        [arr addObject:str];
    }
    NSString *paramsStr = [arr componentsJoinedByString:@"&"];
    if(paramsStr){
        urlStr = [urlStr stringByAppendingFormat:@"?%@",paramsStr];
    }
    return urlStr;
}


/** 增加缓存 */
+ (void)addCacheWithUrl:(NSString *)urlStr sendType:(RMCacheOperationType)sendType dataTask:(NSURLSessionDataTask *)dataTask
{
    if (_cacheArrar == nil) {
        _cacheArrar = [NSMutableArray new];
    }
    // 获取时间戳
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeInterval = [date timeIntervalSince1970]*1000;
    
    RMCacheOperationModel *model = [RMCacheOperationModel new];
    model.operationType   = sendType;
    model.urlStr         = urlStr;
    model.timeInterval    = [NSString stringWithFormat:@"%f",timeInterval];
    model.urlAbsolutiong  = urlStr;
    model.dataTask       = dataTask;
    [self operaModelWithPredicateStr:nil model:model isAdd:YES isDeleteAll:NO];
}

/** 增加缓存 */
+ (void)addCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params sendType:(RMCacheOperationType)sendType dataTask:(NSURLSessionDataTask *)dataTask
{
    if (_cacheArrar == nil) {
        _cacheArrar = [NSMutableArray new];
    }
    
    RMCacheOperationModel *model = [RMCacheOperationModel new];
    model.operationType   = sendType;
    model.urlStr         = urlStr;
    model.timeInterval    = params[@"timestamp"];
    model.urlAbsolutiong  = [self urlAbsolutiongWithUrlStr:urlStr params:params];
    model.dataTask       = dataTask;
    [self operaModelWithPredicateStr:nil model:model isAdd:YES isDeleteAll:NO];
}

/** 移除缓存 */
+ (void)deleteCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params sendType:(RMCacheOperationType)sendType
{
    NSString *predicateStr = [NSString stringWithFormat:@"urlAbsolutiong = '%@' && timeInterval = '%@'",[self urlAbsolutiongWithUrlStr:urlStr params:params],params[@"timestamp"]];
    [self operaModelWithPredicateStr:predicateStr model:nil isAdd:NO isDeleteAll:NO];
}

/**
 添加或移除缓存（TODO:线程安全）
 
 @param predicateStr 谓词（删除必传）
 @param model        模型（添加必传）
 @param isAdd        YES:添加 NO:移除
 @param isDeleteAll  YES:移除所有 NO:不是移除所有（删除必传）
 */
+ (void)operaModelWithPredicateStr:(NSString *)predicateStr
                             model:(RMCacheOperationModel *)model
                             isAdd:(BOOL)isAdd
                       isDeleteAll:(BOOL)isDeleteAll
{
    
    if (![semaphoreLock rm_isNotEmpty]) {
        semaphoreLock = dispatch_semaphore_create(1);
    }
    
    
    // 串行队列的创建方法
    if (![queue rm_isNotEmpty]) {
        queue = dispatch_queue_create("net.rmCacheOperation.singleQueue", DISPATCH_QUEUE_SERIAL);
    }
    
    dispatch_async(queue, ^{
        NSLog(@"currentThred:%@",[NSThread currentThread]);
        // 加锁
        dispatch_semaphore_wait(semaphoreLock, DISPATCH_TIME_FOREVER);
        /** 添加缓存 */
        if (isAdd)
        {
            if (_cacheArrar == nil) {
                _cacheArrar = [NSMutableArray new];
            }
            
            [_cacheArrar addObject:model];
        }
        /** 删除缓存 */
        else
        {
            if (![_cacheArrar rm_isNotEmpty]) {
                // 解锁
                dispatch_semaphore_signal(semaphoreLock);
                return ;
            }
            /** 清除所有缓存 */
            if (isDeleteAll)
            {
                [_cacheArrar removeAllObjects];
            }
            /** 清除搜索缓存所有缓存 */
            else
            {
                NSPredicate *predicate   = [NSPredicate predicateWithFormat:predicateStr];
                NSArray *detinationArray = [_cacheArrar filteredArrayUsingPredicate:predicate];
                if ([detinationArray rm_isNotEmpty]) {
                    [_cacheArrar removeObjectsInArray:detinationArray];
                }
            }
        }
        
        NSLog(@"%@", [NSString stringWithFormat:@"线程：%@ -- 缓存数：%lu", [NSThread currentThread],(unsigned long)_cacheArrar.count]);
        // 解锁
        dispatch_semaphore_signal(semaphoreLock);
    });
}

@end
