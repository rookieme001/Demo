//
//  RMDrawTool.h
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/16.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIView+RMView.h"
NS_ASSUME_NONNULL_BEGIN
@class RMDrawTool;
typedef void(^ToolClickBlock)(RMDrawTool *tool);

@interface RMDrawTool : NSObject
// 绘制图形颜色
@property (nonatomic, strong) UIColor *faceColor;
// 绘制图形点击回调
@property (nonatomic, copy) ToolClickBlock toolClick;
// 是否允许点击绘制图形
@property (nonatomic, assign) BOOL isAllowClick;
// 是否隐藏绘制图形
@property (nonatomic, assign) BOOL isHidden;
// 绘制图形标题
@property (nonatomic, strong) NSString *titleString;
// 绘制图形标题颜色
@property (nonatomic, strong) UIColor *titleColor;
// 绘制图形标题字体大小
@property (nonatomic, strong) UIFont *titleFont;
// 绘制图形标题是否影藏
@property (nonatomic, assign) BOOL labelHidden;
// 是否允许移动
@property (nonatomic, assign ,getter = isAllowMove) BOOL allowMove;

/** 面类型专属属性 */


/** 圆类型专属属性 */

 
/** 点类型专属属性 */
// 点图片（点类型）
@property (nonatomic, strong) UIImage *image;
// 点图片大小（点类型）
@property (nonatomic, assign) CGSize  imageSize;



/** 线类型专属属性 */
// 显示线的拐点
@property (nonatomic, assign) BOOL isShowLineInflexion;
// 线的端点颜色
@property (nonatomic, strong) UIColor *lineTerminalPointColor;
// 线的拐点颜色
@property (nonatomic, strong) UIColor *lineInflexionColor;
// 线宽度（线类型）
@property (nonatomic, assign) CGFloat linPointRadius;
// 线宽度（线类型）
@property (nonatomic, assign) CGFloat linWidth;


/**
 绘制圆面
 
 @param centerPoint 中心点
 @param radius      半径
 @param parentView  父视图
 @return            绘制工具对象
 */
+ (RMDrawTool *)drawCircleWithCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius parentView:(UIView *)parentView;

/**
 绘制面
 
 @param points     面的点数组（不少于3个点）
 @param parentView 父视图
 @return           绘制工具对象
 */
+ (RMDrawTool *)drawFaceWithPoints:(NSArray *)points parentView:(UIView *)parentView;

/**
 绘制线
 
 @param points     线的点集合
 @param parentView 父视图
 @return           绘制工具对象
 */
+ (RMDrawTool *)drawLineWithPoints:(NSArray *)points parentView:(UIView *)parentView;

/**
 绘制点

 @param centerPoint 点中心点
 @param image       点图片
 @param parentView  父视图
 @return            绘制工具对象
 */
+ (RMDrawTool *)drawPointWithCenterPoint:(CGPoint)centerPoint image:(UIImage *)image parentView:(UIView *)parentView;

/**
 刷新圆弧半径和中心点
 
 @param centerPoint 中心点
 @param radius      半径
 */
- (void)changeCirecleCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius;

/**
 刷新不规则面形状
 
 @param points 面的点数组（不少于3个点）
 */
- (void)changeFaceWithPoints:(NSArray *)points;

/**
 刷新线的数据
 
 @param points 线的点数据
 */
- (void)changeLineWithPoints:(NSArray *)points;

/**
 刷新点的位置

 @param centerPoint 点中心点
 */
- (void)changePointCenterPoint:(CGPoint)centerPoint;

/**
 刷新点的位置

 @param centerPoint 点中心点
 @param rotate      点旋转角度
 */
- (void)changePointCenterPoint:(CGPoint)centerPoint rotate:(CGFloat)rotate;

/**
 从父视图移除
 */
- (void)removeFromSuperview;

@end

NS_ASSUME_NONNULL_END
