//
//  YWebViewController.m
//  seaWeather
//
//  Created by 韦海峰 on 2018/12/3.
//

#import "YWebViewController.h"

#import <WebKit/WebKit.h>

@interface YWebViewController ()
//@property (nonatomic, assign) YUrlLinkType linkType;

@property (nonatomic, strong) NSString *msgID;             // 消息ID（自定义）


@property (nonatomic, strong) UIProgressView *progressView;      // 进度条
@property (nonatomic, strong) UIButton *reloadButton;           // 重新加载按钮
@property (nonatomic, assign) BOOL isFaild;                      // 是否加载失败
@property (nonatomic, strong) NSURL *faildUrl;                  // 失败Url
@end

@implementation YWebViewController

- (instancetype)initWithUrl:(NSString *)urlString linkType:(YUrlLinkType)linkType
{
    if (self = [super init]) {
        self.linkType = linkType;
        
        // 传入nil或空值默认为错误操作
        if (urlString == nil || [urlString isEqualToString:@""]) {
            self.linkType = YUrlLinkTypeError;
        }
        
        if (linkType == YUrlLinkTypeRichText) {
            self.richText = urlString;
        } else if ( linkType  == YUrlLinkTypeDefault   ||
                   linkType  == YUrlLinkTypeInnerchain ||
                   linkType  == YUrlLinkTypeOuterchain) {
            self.originalUrlString = urlString;
            self.currentUrlString  = urlString;
        } else if (linkType  == YUrlLinkTypeNative) {
            self.originalUrlString = urlString;
            self.currentUrlString  = urlString;
        } else if (linkType  == YUrlLinkTypeMsgID ) {
            self.msgID = urlString;
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addKVO];
}

- (void)viewDidAppear:(BOOL)animated {
    if (!self.navigationController) {
        UIButton  *backbutton = [[UIButton alloc] init];
        [backbutton addTarget:self action:@selector(backbuttonClick) forControlEvents:UIControlEventTouchUpInside];
        [backbutton setTitle:@" 返回 " forState:UIControlStateNormal];
        [backbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backbutton setBackgroundImage:[UIImage qmui_imageWithColor:[UIColor colorWithRed:212.f/255.f green:84.f/255.f blue:78.f/255.f alpha:1.00]] forState:UIControlStateNormal];
        [backbutton sizeToFit];
        
        
        CGFloat width = ( backbutton.frame.size.width > backbutton.frame.size.height) ? backbutton.frame.size.width : backbutton.frame.size.height;
        backbutton.layer.cornerRadius = width/2.f;
        backbutton.layer.masksToBounds = YES;
        backbutton.alpha = 0.6;
        
        [self.view addSubview:backbutton];
        [backbutton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width);
            make.bottom.equalTo(self.view.mas_bottom).offset(-50.f);
            make.right.equalTo(self.view.mas_right).offset(-15.f);
            make.height.mas_equalTo(width);
        }];
        UIImageView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, StatusBarHeight)];
        self.view.backgroundColor = [UIColor colorWithRed:0.83 green:0.33 blue:0.31 alpha:1.00];
        statusBarView.image = [UIImage qmui_imageWithColor:[UIColor colorWithRed:0.83 green:0.33 blue:0.31 alpha:1.00]];
        [self.view addSubview:statusBarView];
        
        
        
        [_htmlView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).offset(StatusBarHeight);
        }];
    }
    

}

#pragma mark -
#pragma mark - UI搭建
- (void)setupUI
{
    [self setNavigationBarButton];
    [self creatYWkWebView];
    [self creatProcessLine];
    [self creatReloadButton];
}

- (void)setNavigationBarButton {
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    QMUINavigationButton  *backbutton = [[QMUINavigationButton alloc] initWithType:QMUINavigationButtonTypeBack];
    [backbutton addTarget:self action:@selector(myback) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backbutton];
    // 设置返回按钮
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

/**
 创建H5页面
 */
- (void)creatYWkWebView
{
    _htmlView = [[YWebView alloc] init];
    
    if ([_htmlView respondsToSelector:@selector(setNavigationDelegate:)]) {
        [_htmlView setNavigationDelegate:self];
    }
    
    if ([_htmlView respondsToSelector:@selector(setDelegate:)]) {
        [_htmlView setUIDelegate:self];
    }
    
    _htmlView.allowsBackForwardNavigationGestures = NO;
    _htmlView.UIDelegate         = self;
    _htmlView.navigationDelegate  = self;
    // 这行代码可以是侧滑返回webView的上一级，而不是根控制器（*只针对侧滑有效）
    [_htmlView setAllowsBackForwardNavigationGestures:true];
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:_htmlView];
    [self.bridge setWebViewDelegate:self];
    
    
    [self.view addSubview:_htmlView];
    [_htmlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self loadResource];
    [self creatBridgeFunction];
}

/**
 创建重新加载按钮
 */
- (void)creatReloadButton
{
    _reloadButton = [[UIButton alloc] init];
    [_reloadButton setBackgroundColor:[UIColor whiteColor]];
    [_reloadButton setTitle:@"点击重新加载" forState:UIControlStateNormal];
    [_reloadButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_reloadButton addTarget:self action:@selector(reloadCurrentResource) forControlEvents:UIControlEventTouchUpInside];
    [_reloadButton sizeToFit];
    _reloadButton.hidden = YES;
    [self.htmlView addSubview:_reloadButton];
    [_reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width);
        make.top.equalTo(self.view.mas_top).offset(2.f);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

/**
 创建进度条
 */
- (void)creatProcessLine
{
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 2)];
    self.progressView.progressTintColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:0.5f];
    self.progressView.trackTintColor = [UIColor clearColor];
    //设置进度条的高度，下面这句代码表示进度条的宽度变为原来的1倍，高度变为原来的1.5倍.
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.htmlView addSubview:self.progressView];
}

#pragma mark -
#pragma mark - 业务逻辑

#pragma mark - 返回逻辑
- (void)myback
{
    if (_htmlView.canGoBack) { // 优先判断页面能否返回
        [_htmlView goBack];
    }
    else if (_isFaild && _reloadButton.hidden == NO) {
        _isFaild = NO;
        _reloadButton.hidden = YES;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 资源加载业务
/**
 重载资源
 */
- (void)loadResource {
    if (_linkType == YUrlLinkTypeError) {
        return ;
    }
    
    if (_linkType == YUrlLinkTypeRichText)
    {
        [self loadRichText];
    }
    else if ( _linkType    == YUrlLinkTypeDefault   ||
               _linkType  == YUrlLinkTypeInnerchain ||
               _linkType  == YUrlLinkTypeOuterchain)
    {
        [self loadNormalUrl];
    }
    else if (_linkType  == YUrlLinkTypeNative)
    {
 
    }
    else if (_linkType  == YUrlLinkTypeMsgID )
    {
        [self loadResourceByMsgID];
    }
}

/**
 加载富文本
 */
- (void)loadRichText {
    [self.htmlView loadHTMLString:self.richText baseURL:nil];
}

/**
 正常加载url链接地址
 */
- (void)loadNormalUrl {
    // utf-8转码
    NSString *tempString = [self.originalUrlString copy];
    tempString = [YUrlParsingTool appendUrlString:tempString linkType:_linkType];
    tempString = [tempString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    _currentUrlString = tempString;
    self.originalOpreationUrlString = tempString;
    [_htmlView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tempString]]];
}

/**
 通过消息ID请求资源
 */
- (void)loadResourceByMsgID {
//    @weakify(self);
    
//    __weak __typeof(self)weak_self = self;
//    [self showWaitview];
//    [IndexService getMessageInfoWithMsgId:self.msgID completion:^(NSInteger state, NSDictionary *dict) {
////        [weak_self removeWaitview];
//        if (state != 0)
//        {
//            id noticeStr = dict[@"result"][@"msg"];
//            if (!noticeStr) {
//                noticeStr = @"请求失败";
//            }
////            [weak_self showSuggestion:noticeStr showTime:1.5f];
//        }
//        else
//        {
//            if (dict &&
//                [dict isKindOfClass:[NSDictionary class]] &&
//                [dict.allKeys containsObject:@"result"] &&
//                [[dict[@"result"] allKeys] containsObject:@"messageInfo"])
//            {
//                NSDictionary *contentDict = dict[@"result"][@"messageInfo"];
//                weak_self.title = contentDict[@"title"];
//                [weak_self.htmlView loadHTMLString:contentDict[@"content"] baseURL:nil];
//            }
//            else
//            {
////                [weak_self showSuggestion:@"加载失败" showTime:1.5f];
//            }
//        }
//    }];
}


/**
 重新加载当前资源
 */
- (void)reloadCurrentResource {
    [_htmlView loadRequest:[NSURLRequest requestWithURL:_faildUrl]];
}

#pragma mark - 添加JS与原始交互方法
- (void)creatBridgeFunction
{
    __weak __typeof(self)weak_self = self;
    // 打开文件
    [self.bridge registerHandler:@"openFile" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data == nil) {
            return ;
        }
        // data 的类型与 JS中传的参数有关
        NSDictionary *tempDic = data;
        // 在这里执行分享的操作
        NSString *urlStr = [tempDic objectForKey:@"param"];
        [weak_self showAlertWithTitle:@"即将跳转Safari打开该文件" message:nil cancelhandler:nil sureHandler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }];
        // 将分享的结果返回到JS中
        responseCallback(nil);  //回调给JS
    }];
}




#pragma mark - 监听业务
/**
 添加KVO
 */
- (void)addKVO {
    [self.htmlView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.htmlView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}
/** 标题和加载进度监听 */
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"title"]){
        if (object == self.htmlView) {
            if (self.htmlView.title)
            {
               NSString *title = [self.htmlView.title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                self.title = title;
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == self.htmlView) {
            self.progressView.progress = self.htmlView.estimatedProgress;
            if (self.progressView.progress == 1) {
                /*
                 *添加一个简单的动画，将progressView的Height变为1.4倍，在开始加载网页的代理中会恢复为1.5倍
                 *动画时长0.25s，延时0.3s后开始动画
                 *动画结束后将progressView隐藏
                 */
                __weak typeof (self)weakSelf = self;
                [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                    weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
                } completion:^(BOOL finished) {
                    weakSelf.progressView.hidden = YES;
                }];
            }
        } else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

- (void)showAlertWithTitle:(nullable NSString *)title message:(nullable NSString *)message cancelhandler:(void (^ __nullable)(UIAlertAction *action))cancelhandler sureHandler:(void (^ __nullable)(UIAlertAction *action))sureHandler 
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.创建并添加按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelhandler];
    
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    
    // 3.呈现UIAlertContorller
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - H5界面代理
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *URL = navigationAction.request.URL;
    _faildUrl   = URL;
     _currentUrlString = [NSString stringWithFormat:@"%@",URL];
    WKNavigationActionPolicy policy = [self parsingNavigationActionByURL:URL];
    decisionHandler(policy);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
//    [_htmlView removeWaitview];
    //加载完成后隐藏progressView
    [self setWebIsLoadSucess:YES];

    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
//    [_htmlView removeWaitview];
    //加载完成后隐藏progressView
    if (error) {
        [self setWebIsLoadSucess:NO];
    } else {
        [self setWebIsLoadSucess:YES];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    [_htmlView removeWaitview];
    //加载失败同样需要隐藏progressView
    if (error) {
        [self setWebIsLoadSucess:NO];
    } else {
        [self setWebIsLoadSucess:YES];
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
//    [_htmlView removeWaitview];
    [self setWebIsLoadSucess:NO];
}

- (void)setWebIsLoadSucess:(BOOL)isLoadSucess
{
    self.progressView.hidden = YES;
    _reloadButton.hidden = isLoadSucess;
    _isFaild  = !isLoadSucess;
    _faildUrl = isLoadSucess ? nil : _faildUrl;
}

- (WKNavigationActionPolicy)parsingNavigationActionByURL:(NSURL *)URL {
    YUrlSpecialOperationType type = [YUrlParsingTool parsingUrl:URL];
    if (type == YUrlSpecialOperationTypeItunes) { // iTunes链接
        [[UIApplication sharedApplication] openURL:URL];  // 打开iTunes链接
        return WKNavigationActionPolicyCancel;
    }
    
    if (type == YUrlSpecialOperationTypeTel) { // iTunes链接
        NSString *resourceSpecifier = [URL resourceSpecifier];
        NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", resourceSpecifier];
        /// 防止iOS 10及其之后，拨打电话系统弹出框延迟出现
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone]];
        });
        return WKNavigationActionPolicyCancel;
    }
    
    return WKNavigationActionPolicyAllow;
}

- (void)backbuttonClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark 移除观察者
- (void)dealloc
{
    [self.htmlView removeObserver:self forKeyPath:@"title"];
    [self.htmlView removeObserver:self forKeyPath:@"estimatedProgress"];
}

@end
