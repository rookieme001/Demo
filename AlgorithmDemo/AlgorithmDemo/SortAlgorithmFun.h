//
//  SortAlgorithmFun.h
//  AlgorithmDemo
//
//  Created by whf on 1/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SortAlgorithmFun : NSObject

/// 选择排序
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)selectSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

/// 插入排序
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)insertSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

/// 希尔排序
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)shellSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

/// 归并排序
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)mergeSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

/// 基础快速排序（小于中间值、大于等于中间值）
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)quickSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

#pragma mark - TODO 双路快排，左右2路均分中间值（小于等于中间值、大于等于中间值）
+ (void)quick2waySortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

/// 3路快排排序（小于中间值、等于中间值、大于中间值）
/// @param array 数组
/// @param elementCount 数组元素个数
/// @param left 起点值
/// @param right 结束值
+ (void)quick3waySortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;

+ (int)inverseSelectArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;
+ (int)inverseMergeArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right;
@end

NS_ASSUME_NONNULL_END
