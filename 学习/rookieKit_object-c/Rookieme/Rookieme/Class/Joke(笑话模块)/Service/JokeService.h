//
//  JokeService.h
//  Rookieme
//
//  Created by Rookieme on 2019/1/2.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMNetworkManger.h"
NS_ASSUME_NONNULL_BEGIN

@interface JokeService : NSObject
+ (void)getJokeListIsBefore:(BOOL)before time:(NSTimeInterval)time page:(NSInteger)page pagesize:(NSInteger)pagesize CompletionInfo:(void (^)(NSInteger state, NSDictionary *infoDic))completionInfo;
@end

NS_ASSUME_NONNULL_END
