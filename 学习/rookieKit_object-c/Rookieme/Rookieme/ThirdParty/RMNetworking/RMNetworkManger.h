//
//  RMNetworkManger.h
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/** 网络请求基类 */
@interface RMNetworkManger : NSObject
//服务部署地址
@property (nonatomic, strong) NSString *urlStr;
//处理器名
@property (nonatomic, copy) NSString *handler;
//函数名
@property (nonatomic, copy) NSString *method;

/**
 设置参数
 
 @param key    参数名
 @param param  参数值
 */
- (void)rm_setParamByKey:(NSString *)key param:(id)param;

/**
 发送POST请求
 
 @param completionHandler 回调句柄
 */
- (void)rm_postCompletionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler;

/**
 停止请求(TODO:)
 */
//- (void)rm_stop;
@end

NS_ASSUME_NONNULL_END
