//
//  YUrlParsingTool.m
//  seaWeather
//
//  Created by 韦海峰 on 2018/12/3.
//

#import "YUrlParsingTool.h"

@implementation YUrlParsingTool
+ (NSString *)appendUrlString:(NSString *)urlString linkType:(YUrlLinkType)linkType
{
    NSString *string = [urlString copy];
    if (linkType == YUrlLinkTypeDefault || linkType == YUrlLinkTypeInnerchain) {
        // 1、拼接时间戳 (我也不知道是那种规则，都拼接吧！！！小伙)
        string = [self urlStringAppendTimeInterval:string];
        // 1、拼接时间戳 (我也不知道是那种规则，都拼接吧！！！小伙)
        string = [self urlStringAppendTimestamp:string];
        
        // 2、拼接token
//        string = [self urlStringAppendToken:string];
//
//        // 3、拼接serverType
//        string = [self urlStringAppendServerType:string];

    }
    
    return string;
}



/**
 拼接时间戳
 
 @param urlString 链接地址
 @return          处理后链接地址
 */
+ (NSString *)urlStringAppendTimestamp:(NSString *)urlString {
    // 判断是否为nil、空或者包含时间戳
    if (urlString && ![urlString isEqualToString:@""] && ![urlString containsString:@"timestamp"]) {
        // 拷贝字符串
        NSString *string = [urlString copy];
        // 获取13位时间戳
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        // 判断是否有参数选择不同拼接方式
        if ([string containsString:@"?"]) {
            string = [string stringByAppendingFormat:@"&timestamp=%ld",(long)(timeInterval*1000)];
        } else {
            string = [string stringByAppendingFormat:@"?timestamp=%ld",(long)(timeInterval*1000)];
        }
        
        return string;
    }
    return urlString;
}


/**
 拼接时间戳
 
 @param urlString 链接地址
 @return          处理后链接地址
 */
+ (NSString *)urlStringAppendTimeInterval:(NSString *)urlString {
    // 判断是否为nil、空或者包含时间戳
    if (urlString && ![urlString isEqualToString:@""] && ![urlString containsString:@"timeInterval"]) {
        // 拷贝字符串
        NSString *string = [urlString copy];
        // 获取13位时间戳
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        // 判断是否有参数选择不同拼接方式
        if ([string containsString:@"?"]) {
            string = [string stringByAppendingFormat:@"&timeInterval=%ld",(long)(timeInterval*1000)];
        } else {
            string = [string stringByAppendingFormat:@"?timeInterval=%ld",(long)(timeInterval*1000)];
        }
        
        return string;
    }
    return urlString;
}



/**
 拼接serverType
 
 @param urlString 链接地址
 @return          处理后链接地址
 */
//+ (NSString *)urlStringAppendServerType:(NSString *)urlString {
//
//    NSString *serverType = @"3";
//    if ([kUrlStr containsString:@"ehanghai.asuscomm.com:81"])
//    {
//        serverType = @"1";
//    }
//    else if ([kUrlStr containsString:@":81"])
//    {
//        serverType = @"2";
//    }
//
//    NSString *string = [self urlStringRepleaceVaule:urlString byKey:@"serverType" vauleString:serverType];
//
//    return string;
//}
//
//
//+ (NSString *)urlStringAppendToken:(NSString *)urlString {
//    NSString *string = [self urlStringRepleaceVaule:urlString byKey:@"token" vauleString:kUserToken];
//    return string;
//}


+ (NSString *)urlStringRepleaceVaule:(NSString *)urlString byKey:(NSString *)key vauleString:(NSString *)vauleString{
    if (urlString == nil || [urlString isEqualToString:@""]) {
        return urlString;
    }
    // 拷贝字符串
    NSString *string = [urlString copy];
    // 参数转字典
    NSDictionary *dict = [self urlStringconvertTodictionary:string];
    
    if (dict && [dict.allKeys containsObject:key]) {
        NSString *vauleString    = dict[key];
        NSString *originalString = [NSString stringWithFormat:@"%@=%@",key,vauleString];
        NSString *targetString   = [NSString stringWithFormat:@"%@=%@",key,vauleString];
        
        string = [string stringByReplacingOccurrencesOfString:originalString withString:targetString];
        
    } else {
        if ([string containsString:@"?"]) {
            string = [string stringByAppendingFormat:@"&%@=%@",key,vauleString];
        } else {
            string = [string stringByAppendingFormat:@"?%@=%@",key,vauleString];
        }
    }
    return string;
}

+ (NSDictionary *)urlStringconvertTodictionary:(NSString *)urlString
{
    if (urlString && urlString.length && [urlString rangeOfString:@"?"].length == 1) {
        NSArray *array = [urlString componentsSeparatedByString:@"?"];
        if (array && array.count == 2) {
            NSString *paramsStr = array[1];
            if (paramsStr.length) {
                NSMutableDictionary *paramsDict = [NSMutableDictionary dictionary];
                NSArray *paramArray = [paramsStr componentsSeparatedByString:@"&"];
                for (NSString *param in paramArray) {
                    if (param && param.length) {
                        NSArray *parArr = [param componentsSeparatedByString:@"="];
                        if (parArr.count == 2) {
                            [paramsDict setObject:parArr[1] forKey:parArr[0]];
                        }
                    }
                }
                return paramsDict;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    }else{
        return nil;
    }
}

+ (BOOL)urlStringIsNeedShare:(NSString *)urlString {
    NSString *string = [urlString copy];
    BOOL needShare = [string containsString:@"needShare=1"];
    return needShare;
}

+ (YUrlSpecialOperationType)parsingUrl:(NSURL *)URL
{
    /* 简单判断host，真实App代码中，需要更精确判断itunes链接 */
    if ([[URL host] isEqualToString:@"itunes.apple.com"] &&
        [[UIApplication sharedApplication] canOpenURL:URL])
    {
        return YUrlSpecialOperationTypeItunes;
    }
    
    // 拨打电话
    NSString *scheme = [URL scheme];
    if ([scheme isEqualToString:@"tel"])
    {
        return YUrlSpecialOperationTypeTel;
    }
    

    // 会员充值
    NSString *query = [URL query];
    if (query &&
        [[query uppercaseString] rangeOfString:@"VIP"].length  &&
        ![query containsString:@"isVip"])
    {
        return YUrlSpecialOperationTypePay;
    }
    
    // 积分
    if ( query && [query rangeOfString:@"integral"].length)
    {
        return YUrlSpecialOperationTypeIntegral;
    }
    
    return YUrlSpecialOperationTypeNone;
}
@end
