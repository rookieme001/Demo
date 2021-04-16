//
//  MovieTicketService.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "MovieTicketService.h"

@implementation MovieTicketService
+ (void)getMovieTicketCompletionInfo:(void (^)(NSInteger state, NSDictionary *infoDic))completionInfo {
    RMNetworkManger *manger = [[RMNetworkManger alloc] init];
    manger.urlStr = @"http://v.juhe.cn/wepiao/query";
    [manger rm_setParamByKey:@"key" param:@"744092ace39685e05eb2836a624b5769"];
    [manger rm_postCompletionHandler:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        if (error == nil) {
            NSError *trmpError;
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&trmpError];
            
            if (dataDic)
            {
                completionInfo([dataDic[@"error_code"] integerValue],dataDic);
                // 设置网络
                
            } else {
                completionInfo(1,@{@"reason":@"请求失败"});
            }
        }
        
    }];
}
@end
