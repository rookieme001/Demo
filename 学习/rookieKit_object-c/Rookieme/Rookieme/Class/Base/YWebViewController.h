//
//  YWebViewController.h
//  seaWeather
//
//  Created by 韦海峰 on 2018/12/3.
//

#import <UIKit/UIKit.h>
#import "YUrlParsingTool.h"
#import "WKWebViewJavascriptBridge.h"
#import "YWebView.h"
NS_ASSUME_NONNULL_BEGIN

@interface YWebViewController : UIViewController<WKUIDelegate,WKNavigationDelegate,UIAlertViewDelegate>
@property (nonatomic, strong) NSString *originalUrlString; // 原始URL（未处理）
@property (nonatomic, strong) NSString *originalOpreationUrlString; // 原始URL（处理后）
@property (nonatomic, strong) NSString *currentUrlString;  // 当前加载链接
@property (nonatomic, assign) YUrlLinkType linkType; // 链接类型
@property (nonatomic, strong) NSString *richText;          // 富文本
@property (nonatomic, strong) YWebView *htmlView;                // H5页面
// 桥接工具
@property (nonatomic, strong) WKWebViewJavascriptBridge* bridge;

/**
 根据类型配置H5界面

 @param urlString 字符串（url链接或者富文本  消息id（自定义））
 @param linkType  链接类型
 @return          H5控制器
 */
- (instancetype)initWithUrl:(NSString *)urlString linkType:(YUrlLinkType)linkType;


/**
 创建JS交互方法（主要功能：子类拓展重写）
 */
- (void)creatBridgeFunction;


/**
 解析即将调整URL数据，判断是否跳转（主要功能：子类拓展重写）

 @param URL URL
 @return    是否加载
 */
- (WKNavigationActionPolicy)parsingNavigationActionByURL:(NSURL *)URL;

/**
 重新加载当前资源
 */
- (void)reloadCurrentResource;


/**
 返回方法
 */
- (void)myback;

/**
 弹出简单弹框

 @param title 标题
 @param message 类容
 @param cancelhandler 取消按钮点击回调
 @param sureHandler   确定按钮点击回调
 */
- (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelhandler:(void (^ __nullable)(UIAlertAction *action))cancelhandler sureHandler:(void (^ __nullable)(UIAlertAction *action))sureHandler;


/**
 网页是否加载成功调用（子类集成需加载父类方法）

 @param isLoadSucess 是否成功
 */
- (void)setWebIsLoadSucess:(BOOL)isLoadSucess;
@end

NS_ASSUME_NONNULL_END
