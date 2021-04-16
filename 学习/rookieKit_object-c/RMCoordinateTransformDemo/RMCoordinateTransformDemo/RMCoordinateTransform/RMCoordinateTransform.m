//
//  RMCoordinateTransform.m
//  RMCoordinateTransformDemo
//
//  Created by Rookieme on 2018/12/22.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMCoordinateTransform.h"

@implementation RMCoordinateTransform

+ (double)rm_getCoordinateByDegree:(double)degree minute:(double)minute second:(double)second {
    double coordinate = degree + minute/60.f + second/3600.f;
    return coordinate;
}

+ (double)rm_getCoordinateByDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString secondString:(NSString *)secondString {
    double degree = [degreeString doubleValue];
    double minute = [minuteString doubleValue];
    double second = [secondString doubleValue];
    return [self rm_getCoordinateByDegree:degree minute:minute second:second];
}

+ (double)getMinutebyCoordinate:(double)coordinate {
    NSString *coordinateString = [[NSNumber numberWithDouble:coordinate] stringValue];
    /** 取出小数点后面两位(为转化成'分'做准备) */
    NSArray *array = [coordinateString componentsSeparatedByString:@"."];
    /** 小数点后面部分 */
    NSString *lastCompnetString = [array lastObject];
    /** 拼接字字符串(将字符串转化为0.xxxx形式) */
    NSString *minuteString = [NSString stringWithFormat:@"0.%@", lastCompnetString];
    return [minuteString doubleValue]*60.f;
}

+ (double)getSecondbyCoordinate:(double)coordinate {
    double minute = [self getMinutebyCoordinate:coordinate];
    NSString *minuteString = [[NSNumber numberWithDouble:minute] stringValue];
    NSArray *array = [minuteString componentsSeparatedByString:@"."];
    /** 小数点后面部分 */
    NSString *lastCompnetString = [array lastObject];
    /** 拼接字字符串(将字符串转化为0.xxxx形式) */
    NSString *secondString = [NSString stringWithFormat:@"0.%@", lastCompnetString];
    return [secondString doubleValue]*60.f;
}

+ (NSString *)rm_transformCoordinate:(double)coordinate format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision {
    
    double degree = [self rm_getCoordinateByDegree:coordinate minute:0.f second:0.f];
    double minute = [self getMinutebyCoordinate:degree];
    double second = [self getSecondbyCoordinate:degree];
    
    NSString *coordinateStr = @"";
    
    if (format == RMCoordinateTransformFormatDefault) {
        NSString *secondStr = [self rm_doubleVauleTransformToString:second precision:precision];
        coordinateStr = [NSString stringWithFormat:@"%d°%02d′%@′′",(int)floor(degree),(int)floor(minute),secondStr];
    } else if (format == RMCoordinateTransformFormatDegreeAndMinute) {
        NSString *minuteStr = [self rm_doubleVauleTransformToString:minute precision:precision];
        coordinateStr = [NSString stringWithFormat:@"%d°%@′",(int)floor(degree),minuteStr];
    } else if (format == RMCoordinateTransformFormatDegree) {
        coordinateStr = [self rm_doubleVauleTransformToString:degree precision:precision];
    }
    return coordinateStr;
}

+ (NSString *)rm_transformCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision {
    return [self rm_transformCoordinate:[coordinateString doubleValue] format:format precision:precision];
}


+ (NSString *)rm_transformDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision{
    return [self rm_transformDegree:[degreeString doubleValue] minute:[minuteString doubleValue] format:format precision:precision];
}


+ (NSString *)rm_transformDegree:(double)degree minute:(double)minute format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision{
    
    double coordinate = [self rm_getCoordinateByDegree:degree minute:minute second:0.f];
    return [self rm_transformCoordinate:coordinate format:format precision:precision];
}


+ (NSString *)rm_transformDegreeString:(NSString *)degreeString minuteString:(NSString *)minuteString secondString:(NSString *)secondString format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision{
    return [self rm_transformDegree:[degreeString doubleValue] minute:[minuteString doubleValue] second:[secondString doubleValue] format:format precision:precision];
}


+ (NSString *)rm_transformDegree:(double)degree minute:(double)minute second:(double)second format:(RMCoordinateTransformFormat)format precision:(NSInteger)precision {
    double coordinate = [self rm_getCoordinateByDegree:degree minute:minute second:second];
    return [self rm_transformCoordinate:coordinate format:format precision:precision];
}


+ (NSArray *)rm_interceptCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format {
    
    double coordinate = 0.0f;
    if (format == RMCoordinateTransformFormatDefault) {
        if ([coordinateString containsString:@"°"] && [coordinateString containsString:@"′′"]) {
            NSString *tempStr = [coordinateString stringByReplacingOccurrencesOfString:@"′′" withString:@""];
            if ([tempStr containsString:@"′"]) {
                NSArray *firstArray = [coordinateString componentsSeparatedByString:@"°"];
                NSString *str1      = [firstArray firstObject];
                NSArray *secondArray = [[firstArray lastObject] componentsSeparatedByString:@"′"];
                NSString *str2 = [secondArray firstObject];
                NSString *str3 = [secondArray[1] stringByReplacingOccurrencesOfString:@"′" withString:@""];
                coordinate = [self rm_getCoordinateByDegreeString:str1 minuteString:str2 secondString:str3];
            }
        }
    } else if (format == RMCoordinateTransformFormatDegreeAndMinute) {
        if ([coordinateString containsString:@"°"] && [coordinateString containsString:@"′"]
            && ![coordinateString containsString:@"′′"]) {
            NSArray *firstArray = [coordinateString componentsSeparatedByString:@"°"];
            NSString *str1      = [firstArray firstObject];
            NSString *str2      = [[firstArray lastObject] stringByReplacingOccurrencesOfString:@"′" withString:@""];
            coordinate = [self rm_getCoordinateByDegree:[str1 doubleValue] minute:[str2 doubleValue] second:0.f];
        }
    } else if (format == RMCoordinateTransformFormatDegree) {
        coordinate = [self rm_getCoordinateByDegree:[coordinateString doubleValue] minute:0.f second:0.f];
    }
    return [self rm_interceptCoordinate:coordinate];
}

+ (NSArray *)rm_interceptCoordinate:(double)coordinate {
    NSString *degreeString = [[NSNumber numberWithDouble:coordinate] stringValue];
    NSString *minuteString = [[NSNumber numberWithDouble:[self getMinutebyCoordinate:coordinate]] stringValue];
    NSString *secondString = [[NSNumber numberWithDouble:[self getSecondbyCoordinate:coordinate]] stringValue];
    return @[degreeString,minuteString,secondString];
}

+ (NSArray *)rm_interceptCoordinateString:(NSString *)coordinateString format:(RMCoordinateTransformFormat)format targetFormat:(RMCoordinateTransformFormat)targetFormat precision:(NSInteger)precision{
    NSArray *sourceArray = [self rm_interceptCoordinateString:coordinateString format:format];
    NSString *degreeString = sourceArray[0];
    NSString *minuteString = sourceArray[1];
    NSString *secondString = sourceArray[2];
    if (targetFormat == RMCoordinateTransformFormatDefault) {
        degreeString = [NSString stringWithFormat:@"%.0f",floor([degreeString doubleValue])];
        minuteString = [NSString stringWithFormat:@"%.0f",floor([minuteString doubleValue])];
        secondString = [self rm_doubleVauleTransformToString:[secondString doubleValue] precision:precision];
        return @[degreeString,minuteString,secondString];
    } else if (targetFormat == RMCoordinateTransformFormatDegreeAndMinute) {
        degreeString = [NSString stringWithFormat:@"%.0f",floor([degreeString doubleValue])];
        minuteString = [self rm_doubleVauleTransformToString:[minuteString doubleValue] precision:precision];
        return @[degreeString,minuteString];
    } else if (targetFormat == RMCoordinateTransformFormatDegree) {
        secondString = [self rm_doubleVauleTransformToString:[degreeString doubleValue] precision:precision];
        return @[secondString];
    }
    return nil;
}

+ (NSArray *)rm_interceptCoordinate:(double)coordinate targetFormat:(RMCoordinateTransformFormat)targetFormat precision:(NSInteger)precision {
    NSString *degreeString = [[NSNumber numberWithDouble:coordinate] stringValue];
    NSString *minuteString = [[NSNumber numberWithDouble:[self getMinutebyCoordinate:coordinate]] stringValue];
    NSString *secondString = [[NSNumber numberWithDouble:[self getSecondbyCoordinate:coordinate]] stringValue];
    if (targetFormat == RMCoordinateTransformFormatDefault) {
        degreeString = [NSString stringWithFormat:@"%.0f",floor([degreeString doubleValue])];
        minuteString = [NSString stringWithFormat:@"%.0f",floor([minuteString doubleValue])];
        secondString = [self rm_doubleVauleTransformToString:[secondString doubleValue] precision:precision];
        return @[degreeString,minuteString,secondString];
    } else if (targetFormat == RMCoordinateTransformFormatDegreeAndMinute) {
        degreeString = [NSString stringWithFormat:@"%.0f",floor([degreeString doubleValue])];
        minuteString = [self rm_doubleVauleTransformToString:[minuteString doubleValue] precision:precision];
        return @[degreeString,minuteString];
    } else if (targetFormat == RMCoordinateTransformFormatDegree) {
        secondString = [self rm_doubleVauleTransformToString:[degreeString doubleValue] precision:precision];
        return @[secondString];
    }
    return nil;
}

+ (NSString *)rm_doubleVauleTransformToString:(double)doubleVaule precision:(NSInteger)precision {
    NSString *tempString = [[NSNumber numberWithDouble:doubleVaule] stringValue];
    NSString *precisionString = [NSString stringWithFormat:@"%%.%ldf",precision];
    NSString *targetString    = [NSString stringWithFormat:precisionString,doubleVaule];
    // 如果超出doule类型进度，则取最大精度，后面补0
    if (targetString.length >= tempString.length) {
        for (NSInteger index = 0; index < (targetString.length - tempString.length); index++) {
           tempString = [tempString stringByAppendingString:@"0"];
        }
        return tempString;
    }
    return targetString;
}

@end
