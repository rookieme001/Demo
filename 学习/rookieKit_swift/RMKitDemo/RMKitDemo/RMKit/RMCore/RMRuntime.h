//
//  RMRuntime.h
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface RMRuntime : NSObject
/**
 同一个 class 对象方法的交换

 @param anClass        哪个类
 @param originSelector 原本的方法
 @param newSelector    要替换成的方法
 @return               是否成功替换（或增加）
 */
+ (BOOL)rm_exchangeInstanceMethod:(Class)anClass originSelector:(SEL)originSelector newSelector:(SEL)newSelector;


/**
 不同 class 对象方法的交换

 @param fromClass      被替换的 class，不能为空
 @param originSelector 被替换的 class 的 selector，可为空，为空则相当于为 fromClass 新增这个方法
 @param toClass        用这个 class 的方法来替换
 @param newSelector    用 toClass 里的这个方法来替换 originSelector
 @return               是否成功替换（或增加）
 */
+ (BOOL)rm_exchangeInstanceMethodFromClass:(Class)fromClass originSelector:(SEL)originSelector toClass:(Class)toClass newSelector:(SEL)newSelector;
@end

NS_ASSUME_NONNULL_END
