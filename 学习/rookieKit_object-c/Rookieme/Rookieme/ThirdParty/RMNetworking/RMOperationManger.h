//
//  RMOperationManger.h
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMOperationManger : NSObject

// 停止所有网络请求，后面不再执行网络请求
@property (nonatomic, assign) BOOL stopAllRequest;

/**
 添加网络请求缓存
 
 @param urlStr 服务部署地址+处理器名+函数名
 @param params 参数
 @param task   任务
 */
+ (void)addRequestByUrlstr:(NSString *)urlStr params:(NSDictionary *)params task:(NSURLSessionDataTask *)task;


/**
 移除缓存
 
 @param urlStr  服务部署地址+处理器名+函数名
 @param params  参数
 */
+ (void)removeCacheByUrlstr:(NSString *)urlStr params:(NSDictionary *)params;


///** 取消所有网络请求 */
//+ (void)cancelAllrequest;
//
///**
// 取消网络请求（不包含参数）
// 
// @param urlStr URL字符串
// */
//+ (void)cancelRequestByUrlstr:(NSString *)urlStr;
//
///**
// 取消网络请求（包含参数）
// 
// @param urlStr 服务部署地址+处理器名+函数名
// @param params  参数
// */
//+ (void)cancelRequestByUrlstr:(NSString *)urlStr params:(NSDictionary *)params;
@end

NS_ASSUME_NONNULL_END
