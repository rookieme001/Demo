//
//  RMCacheOperationManger.h
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMCacheOperationModel.h"
NS_ASSUME_NONNULL_BEGIN
/** 操作缓存处理类 */
@interface RMCacheOperationManger : NSObject

+ (void)addCacheWithUrl:(NSString *)urlStr sendType:(RMCacheOperationType)sendType dataTask:(NSURLSessionDataTask *)dataTask;

+ (void)addCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params sendType:(RMCacheOperationType)sendType dataTask:(NSURLSessionDataTask *)dataTask;
// 删
//+ (void)deleteCacheWithUrl:(NSString *)urlStr sendType:(RMCacheOperationType)sendType;

+ (void)deleteCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params sendType:(RMCacheOperationType)sendType;

//+ (void)deleteAllCache;
// 查
//+ (NSURLSessionDataTask *)findDataTaskCacheWithUrl:(NSString *)urlStr params:(NSDictionary *)params sendType:(RMCacheOperationType)sendType;
//
//+ (NSArray *)findDataTaskCacheWithUrl:(NSString *)urlStr sendType:(RMCacheOperationType)sendType;
//
//+ (NSArray *)findAll;
@end

NS_ASSUME_NONNULL_END
