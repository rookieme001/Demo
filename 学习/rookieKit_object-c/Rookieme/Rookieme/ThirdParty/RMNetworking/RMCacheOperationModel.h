//
//  RMCacheOperationModel.h
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
/** 网络操作临时缓存模型 */
// TODO：设计临时缓存方案
typedef NS_ENUM(NSUInteger, RMCacheOperationType) {
    RMCacheOperationTypeGet,
    RMCacheOperationTypePost,
    RMCacheOperationTypeDownload,
    RMCacheOperationTypeUpload,
};
NS_ASSUME_NONNULL_BEGIN

@interface RMCacheOperationModel : NSObject

// 请求方式
@property (nonatomic, assign) RMCacheOperationType operationType;
// 时间戳
@property (nonatomic, strong) NSString *timeInterval;
// url
@property (nonatomic, strong) NSString *urlStr;
// parms
@property (nonatomic, strong) NSDictionary *parms;
// absolutiong
@property (nonatomic, strong) NSString *urlAbsolutiong;
// dataTask
@property (nonatomic, weak) NSURLSessionDataTask *dataTask;
@end

NS_ASSUME_NONNULL_END
