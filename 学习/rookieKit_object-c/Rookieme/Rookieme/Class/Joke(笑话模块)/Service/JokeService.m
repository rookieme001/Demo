//
//  JokeService.m
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "JokeService.h"

@implementation JokeService
+ (void)getJokeListIsBefore:(BOOL)before time:(NSTimeInterval)time page:(NSInteger)page pagesize:(NSInteger)pagesize CompletionInfo:(void (^)(NSInteger state, NSDictionary *infoDic))completionInfo {
    RMNetworkManger *manger = [[RMNetworkManger alloc] init];
    manger.urlStr = @"http://v.juhe.cn/joke/content/list.php";
    [manger rm_setParamByKey:@"sort" param:(before ? @"desc" : @"asc")];
    [manger rm_setParamByKey:@"page" param:@(page)];
    [manger rm_setParamByKey:@"pagesize" param:@(pagesize)];
    [manger rm_setParamByKey:@"time" param:@((long)time)];
    [manger rm_setParamByKey:@"key" param:@"c966549f8d67e11181b82f0966597f2f"];
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

//http://v.juhe.cn/joke/content/list.php?pagesize=20&key=c966549f8d67e11181b82f0966597f2f&sort=desc&time=1546404587.367538&page=1

@end
