//
//  YUrlParsingTool.h
//  seaWeather
//
//  Created by 韦海峰 on 2018/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YUrlLinkType) {
    YUrlLinkTypeDefault = 0,  // 默认（内链-自定义）
    YUrlLinkTypeInnerchain,   // 内链（自定义）
    YUrlLinkTypeOuterchain,   // 外链
    YUrlLinkTypeRichText,     // 富文本
    YUrlLinkTypeMsgID,        // 消息ID（自定义）
    YUrlLinkTypeNative,       // 原生  （自定义）
    YUrlLinkTypeError,        // 不执行任何操作
};

typedef NS_ENUM(NSUInteger, YUrlSpecialOperationType) {
    YUrlSpecialOperationTypeNone,    // 非特殊操作
    YUrlSpecialOperationTypeItunes,  // itunes链接（系统）
    YUrlSpecialOperationTypeTel,     // 拨打电话（系统）
    YUrlSpecialOperationTypePay,     // 支付（自定义）
    YUrlSpecialOperationTypeIntegral // 积分（自定义）
};

@interface YUrlParsingTool : NSObject
/**
 根据链接类型拼接url

 @param urlString 链接
 @param linkType  链接类型
 @return          处理后链接
 */
+ (NSString *)appendUrlString:(NSString *)urlString linkType:(YUrlLinkType)linkType;

/**
 判断该链接是否展示分享
 
 @param urlString 链接
 @return          是否展示分享
 */
+ (BOOL)urlStringIsNeedShare:(NSString *)urlString;


/**
 单个参数拼接（有则替换，无则拼接）

 @param urlString    链接
 @param key          参数名
 @param vauleString  值
 @return             拼接后链接
 */
+ (NSString *)urlStringRepleaceVaule:(NSString *)urlString byKey:(NSString *)key vauleString:(NSString *)vauleString;


/**
 拦截url解析其 是否 调用特殊操作回调

 @param URL URL
 @return 是否 调用特殊操作回调
 */
+ (YUrlSpecialOperationType)parsingUrl:(NSURL *)URL;
@end

NS_ASSUME_NONNULL_END
