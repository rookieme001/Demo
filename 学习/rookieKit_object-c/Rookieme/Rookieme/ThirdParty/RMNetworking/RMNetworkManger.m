//
//  RMNetworkManger.m
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMNetworkManger.h"
#import "NSObject+RMNetwork.h"
#import "RMOperationManger.h"
#import "RMNetworkCommons.h"
#define NetTimeoutInterval 30



@interface RMNetworkManger ()
@property (nonatomic, strong) NSMutableDictionary *params;
@end

@implementation RMNetworkManger
/** 添加参数 */
- (void)rm_setParamByKey:(NSString *)key param:(id)param
{
    if (![key rm_isNotEmpty]) {
        return ;
    }
    
    if (![_params rm_isNotNull])
    {
        _params = [NSMutableDictionary new];
    }
    
    if (![param rm_isNotEmpty]) {
        param = @"";
    }
    
    [_params setObject:param forKey:key];
}

/** 拼接url路径 */
- (NSString *)generateURL{
    
    NSMutableString *url = [NSMutableString string];
    if (_urlStr) {
        [url appendString:_urlStr];
    }
    if (_handler) {
        [url appendFormat:@"/%@",_handler];
    }
    if (_method) {
        [url appendFormat:@"/%@",_method];
    }
    return url;
}

/** 拼接完整url */
- (NSString *)description{
    
    NSString *urlStr = [self generateURL];
    NSURL *url = [NSURL URLWithString:urlStr relativeToURL:[NSURL URLWithString:_urlStr]];
    urlStr = url.absoluteString;
    NSMutableArray *arr = [NSMutableArray new];
    for(NSString *key in [_params allKeys]){
        NSString *str = [key stringByAppendingFormat:@"=%@",[_params[key] rm_isNotEmpty]?_params[key]:@""];
        [arr addObject:str];
    }
    NSString *params = [arr componentsJoinedByString:@"&"];
    if(params){
        urlStr = [urlStr stringByAppendingFormat:@"?%@",params];
    }
    return urlStr;
}

- (NSString *)generateParams {
    NSString *paramsStr = @"";
    NSMutableArray *arr = [NSMutableArray new];
    for(NSString *key in [_params allKeys]){
        NSString *str = [key stringByAppendingFormat:@"=%@",_params[key] ? _params[key]:@""];
        [arr addObject:str];
    }
    NSString *params = [arr componentsJoinedByString:@"&"];
    if(params){
        paramsStr = [paramsStr stringByAppendingFormat:@"%@",params];
    }
    return paramsStr;
}

/** 发送POST请求 */
- (void)rm_postCompletionHandler:(void(^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler
{
    // 获取url路径
    NSString *urlStr = [self generateURL];
    NSURL *url = [NSURL URLWithString:urlStr];
    // 配置request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:NetTimeoutInterval];
    // 设置请求方法为POST
    request.HTTPMethod = @"POST";
    // 设置请求体
    if (_params) {
   
        request.HTTPBody = [[self generateParams] dataUsingEncoding:NSUTF8StringEncoding];

        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:_params];
        //配置13位时间戳（注入缓存用）
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSString *timestamp = [NSString stringWithFormat:@"%f",timeInterval*1000];
        [dict setObject:timestamp forKey:@"timestamp"];
        
        
        // 获取session
        NSURLSession *urlSession = [NSURLSession sharedSession];
        // 开启请求任务，默认任务是挂起，需要手动开启
        NSURLSessionDataTask *dataTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 从缓存缓存移除
            [RMOperationManger removeCacheByUrlstr:urlStr params:dict];
            if (completionHandler) {
                completionHandler(data,response,error);
            }
        }];
        // 开启网络请求
        [dataTask resume];
        
        // 注入缓存
        [RMOperationManger addRequestByUrlstr:urlStr params:dict task:dataTask];
    }
}


@end
