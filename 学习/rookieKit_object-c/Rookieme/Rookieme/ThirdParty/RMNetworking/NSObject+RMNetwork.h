//
//  NSObject+RMNetwork.h
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (RMNetwork)
/**
 数据非空判断,字符串数组字典如已初始化,判断为YES
 
 @return 是否为空
 */
- (BOOL)rm_isNotNull;


/**
 数据内容非空判断,字符串数组字典如已初始化,但内容为空,判断为NO
 
 @return 是否为空
 */
- (BOOL)rm_isNotEmpty;
@end

NS_ASSUME_NONNULL_END
