//
//  RMOperationManger.m
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMOperationManger.h"
#import "RMCacheOperationManger.h"
@implementation RMOperationManger
+ (void)addRequestByUrlstr:(NSString *)urlStr params:(NSDictionary *)params task:(NSURLSessionDataTask *)task
{
    [RMCacheOperationManger addCacheWithUrl:urlStr params:params sendType:RMCacheOperationTypePost dataTask:task];
}

+ (void)removeCacheByUrlstr:(NSString *)urlStr params:(NSDictionary *)params
{
    [RMCacheOperationManger deleteCacheWithUrl:urlStr params:params sendType:RMCacheOperationTypePost];
}
@end
