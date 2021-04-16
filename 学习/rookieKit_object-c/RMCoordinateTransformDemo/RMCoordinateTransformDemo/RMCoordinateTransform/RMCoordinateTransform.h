//
//  RMCoordinateTransform.h
//  RMCoordinateTransformDemo
//
//  Created by Rookieme on 2018/12/22.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RMCoordinateTransformFormat) {
    RMCoordinateTransformFormatDefault,         // 默认度分秒（**°**‘**.**’‘）
    RMCoordinateTransformFormatDegreeAndMinute, // 度分（**°**.**‘）
    RMCoordinateTransformFormatDegree,          // 度（**.**°）
};

@interface RMCoordinateTransform : NSObject


#pragma mark -
#pragma mark - 转换API
/**
 经纬度转换（字符串）

 @param coordinateString 经纬度字符串
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;


/**
 经纬度转换（double）

 @param coordinate 经纬度（double）
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformCoordinate:(double)coordinate format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;

/**
 经纬度-度分转换（字符串）

 @param degreeString     经纬度-度字符串
 @param minuteString     经纬度-分字符串
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;


/**
 经纬度-度分转换（double）

 @param degree           经纬度-度double
 @param minute           经纬度-分double
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformDegree:(double)degree minute:(double)minute format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;

/**
 经纬度-度分秒转换（字符串）

 @param degreeString     经纬度-度字符串
 @param minuteString     经纬度-分字符串
 @param secondString     经纬度-秒字符串
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString secondString:(NSString *)secondString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;


/**
 经纬度-度分秒转换（double）

 @param degree           经纬度-度double
 @param minute           经纬度-分double
 @param second           经纬度-秒double
 @param format           转换格式
 @param precision        末尾小数位数
 @return                 经纬度字符串
 */
+ (NSString *)rm_transformDegree:(double)degree minute:(double)minute second:(double)second format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision;

/**
 获取经纬度值
 
 @param degree 度
 @param minute 分
 @param second 秒
 @return       经纬度值
 */
+ (double)rm_getCoordinateByDegree:(double)degree minute:(double)minute second:(double)second;

/**
 获取经纬度值
 
 @param degreeString 度字符串
 @param minuteString 分字符串
 @param secondString 秒字符串
 @return             经纬度值
 */
+ (double)rm_getCoordinateByDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString secondString:(NSString *)secondString;

#pragma mark -
#pragma mark - 分解API
/**
 根据经纬度格式解析字符串

 @param coordinateString 经纬度字符串
 @param format           经纬度格式
 @return                 double类型度分秒值
 */
+ (NSArray *)rm_interceptCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format;

/**
 解析经纬度（示例-格式 返回值：double类型数据数组）
 
 @param coordinate 经纬度
 @return           double类型度分秒值
 */
+ (NSArray *)rm_interceptCoordinate:(double)coordinate;



/**
 根据经纬度格式解析字符串（示例-targetFormat：RMCoordinateTransformFormatDefault 返回值：@[@"120",@"14",@"12.22"]）

 @param coordinateString 经纬度字符串
 @param format           经纬度格式
 @param targetFormat     目标经纬度格式
 @param precision        目标数据，最后一个数据精度
 @return                 目标数据数组
 */
+ (NSArray *)rm_interceptCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format targetFormat:(RMCoordinateTransformFormat)targetFormat precision:(NSInteger)precision;



/**
 解析经纬度（示例-targetFormat：RMCoordinateTransformFormatDefault 返回值：@[@"120",@"14",@"12.22"]）

 @param coordinate   经纬度
 @param targetFormat 目标经纬度格式
 @param precision    目标数据，最后一个数据精度
 @return             目标数据数组
 */
+ (NSArray *)rm_interceptCoordinate:(double)coordinate targetFormat:(RMCoordinateTransformFormat)targetFormat precision:(NSInteger)precision;


/**
 double类型数据转字符串

 @param doubleVaule double类型数据
 @param precision   精度
 @return            字符串
 */
+ (NSString *)rm_doubleVauleTransformToString:(double)doubleVaule precision:(NSInteger)precision;

@end

NS_ASSUME_NONNULL_END
