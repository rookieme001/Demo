//
//  RMDrawTool.m
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/16.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import "RMDrawTool.h"
#import "RMDrawPointJudge.h"
#import "RMDrawView.h"
#import "RMDrawShapeLayer.h"
#import "RMDrawButton.h"
#define kWeakSelf(weak_self) __weak __typeof(&*self) weak_self = self
@interface RMDrawTool ()<RMDrawViewDelegate,RMDrawButtonDelegate>
// 绘制类型
@property (nonatomic, assign) RMDrawToolType tooltype;
// 绘制所用视图view
@property (nonatomic, strong) RMDrawView *faceView;
// 父视图
@property (nonatomic, weak)   UIView *parentView;
// 绘制路径，面专用
@property (nonatomic, strong) UIBezierPath *facePath;
// 遮罩层（面专用）
@property (nonatomic, strong) CAShapeLayer *shaperLayer;
// 路径
@property (nonatomic, strong) NSArray *path;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;
// 圆半径
@property (nonatomic, assign) CGFloat radius;
// 圆中心点
@property (nonatomic, assign) CGPoint centerPoint;
// 线标题相对位置
@property (nonatomic, assign) CGPoint convertPoint;
// 路径
@property (nonatomic, strong) NSArray *convertPoints;
@end

@implementation RMDrawTool

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
    }
    return _titleLabel;
}

// 创建可点击视图
- (RMDrawView *)rm_creatView
{
    RMDrawView *view = [[RMDrawView alloc] init];
    view.delegate = self;
    UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
    tap.numberOfTapsRequired = 1;
    [tap addTarget:self action:@selector(toolViewClick:)];
    [view addGestureRecognizer:tap];
    return view;
}

+ (RMDrawTool *)rm_creatFaceToolWithParentView:(UIView *)parentView
{
    // 基础子控件配置
    RMDrawTool *tool = [[RMDrawTool alloc] init];
    
    tool.parentView  = parentView;
    tool.faceView    = [tool rm_creatView];
    [tool.parentView addSubview:tool.faceView];
    // 遮罩配置
    tool.shaperLayer           = [CAShapeLayer layer];
    tool.faceView.layer.mask   = tool.shaperLayer;
    tool.shaperLayer.fillColor = [UIColor whiteColor].CGColor;
    return tool;
}

+ (RMDrawTool *)drawCircleWithCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius parentView:(UIView *)parentView
{
    RMDrawTool *tool = [self rm_creatFaceToolWithParentView:parentView];
    tool.tooltype    = RMDrawToolTypeCircle;
    tool.faceView.type = RMDrawToolTypeCircle;
    tool.shaperLayer.lineWidth = 0.000001f;
    [tool changeCirecleCenterPoint:centerPoint radius:radius];
    return tool;
}

+ (RMDrawTool *)drawFaceWithPoints:(NSArray *)points parentView:(UIView *)parentView
{
    if (!points || points.count < 3) { return nil;}
    
    RMDrawTool *tool = [self rm_creatFaceToolWithParentView:parentView];
    tool.tooltype    = RMDrawToolTypeFace;
    tool.faceView.type = RMDrawToolTypeFace;
    [tool changeFaceWithPoints:points];
    return tool;
}

+ (RMDrawTool *)drawLineWithPoints:(NSArray *)points parentView:(UIView *)parentView
{
    RMDrawTool *tool = [self rm_creatFaceToolWithParentView:parentView];
    tool.tooltype    = RMDrawToolTypeLine;
    tool.faceView.type = RMDrawToolTypeLine;
    tool.shaperLayer.lineWidth = 2.0;
    tool.shaperLayer.strokeColor = [UIColor grayColor].CGColor;
    tool.shaperLayer.fillColor = nil; // 默认为blackColor
    tool.shaperLayer.lineCap = kCALineCapRound;
    tool.shaperLayer.lineJoin = kCALineJoinRound;
    
    
    [tool changeLineWithPoints:points];
    return tool;
}

+ (RMDrawTool *)drawPointWithCenterPoint:(CGPoint)centerPoint image:(UIImage *)image parentView:(UIView *)parentView
{
    RMDrawTool *tool = [[RMDrawTool alloc] init];
    tool.tooltype    = RMDrawToolTypePoint;
    tool.image       = image;
    tool.centerPoint = centerPoint;
    tool.parentView  = parentView;
    RMDrawButton *button = [RMDrawButton new];
    button.delegate      = tool;
    tool.faceView    = (RMDrawView  *)button;
    [((UIButton *)tool.faceView) setBackgroundImage:image forState:UIControlStateNormal];
    [((UIButton *)tool.faceView) addTarget:tool action:@selector(pointimageclick:) forControlEvents:UIControlEventTouchUpInside];
    [tool changePointCenterPoint:centerPoint];
    [tool.parentView addSubview:tool.faceView];
    return tool;
}

- (void)changeFaceWithPoints:(NSArray *)points
{
    if (!points || points.count < 3) {
        return ;
    }
    
    if (self.tooltype != RMDrawToolTypeFace) {
        return ;
    }
    
    _path = points;
    kWeakSelf(weak_self);
    _facePath = [UIBezierPath new];
    
    __block CGFloat minX;
    __block CGFloat minY;
    __block CGFloat maxX;
    __block CGFloat maxY;
    
    [points enumerateObjectsUsingBlock:^(NSString *pointSring, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointSring);
        if (index == 0) {
            minX = point.x;
            minY = point.y;
            maxX = point.x;
            maxY = point.y;
        } else {
            minX = (minX > point.x) ? point.x : minX;
            minY = (minY > point.y) ? point.y : minY;
            maxX = (maxX < point.x) ? point.x : maxX;
            maxY = (maxY < point.y) ? point.y : maxY;
        }
    }];
    
    [points enumerateObjectsUsingBlock:^(NSString *pointSring, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointSring);
        if (index == 0) {
            [weak_self.facePath moveToPoint:CGPointMake(point.x-minX, point.y-minY)];
        } else {
            [weak_self.facePath addLineToPoint:CGPointMake(point.x-minX, point.y-minY)];
        }
    }];
    
    CGFloat faceViewW = maxX - minX;
    CGFloat faceViewH = maxY - minY;
    self.faceView.frame = CGRectMake(minX, minY, faceViewW, faceViewH);
    
    if (_titleString) {
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(faceViewW/2.f+minX, faceViewH/2.f+minY);
    }
    
    _shaperLayer.path      = _facePath.CGPath;
}

- (void)changeLineWithPoints:(NSArray *)points
{
    
    
    if (!points || points.count <= 0) {
        return ;
    }
    
    if (self.tooltype != RMDrawToolTypeLine) {
        return ;
    }
    
    if (_shaperLayer.sublayers) {
        for (id layer in [_shaperLayer.sublayers copy]) {
            if ([layer isKindOfClass:[RMDrawShapeLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
    }

     kWeakSelf(weak_self);
    _path     = points;
    _facePath = [UIBezierPath new];
    _facePath.lineWidth    = _linWidth;
    _shaperLayer.lineWidth = _linWidth;
    __block CGFloat minX;
    __block CGFloat minY;
    __block CGFloat maxX;
    __block CGFloat maxY;
    
    [points enumerateObjectsUsingBlock:^(NSString *pointSring, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointSring);
        if (index == 0) {
            minX = point.x;
            minY = point.y;
            maxX = point.x;
            maxY = point.y;
        } else {
            minX = (minX > point.x) ? point.x : minX;
            minY = (minY > point.y) ? point.y : minY;
            maxX = (maxX < point.x) ? point.x : maxX;
            maxY = (maxY < point.y) ? point.y : maxY;
        }
    }];
    
    [points enumerateObjectsUsingBlock:^(NSString *pointSring, NSUInteger index, BOOL * _Nonnull stop) {
        CGPoint point = CGPointFromString(pointSring);
        
        CGPoint targetPoint = CGPointMake(point.x-minX+weak_self.linWidth, point.y-minY+weak_self.linWidth);
        if (index == 0) {
            [weak_self.facePath moveToPoint:targetPoint];
            
            if (points.count == 1) {
                [weak_self.facePath addLineToPoint:targetPoint];
            }
            
        } else {
            [weak_self.facePath addLineToPoint:targetPoint];
        }
        
        if (weak_self.isShowLineInflexion) {
            RMDrawShapeLayer *pointLayer;
            if (index == 0 || index == points.count-1) {
                pointLayer = [weak_self drawPointToPolyPoint:targetPoint clolor:weak_self.lineTerminalPointColor];
            } else {
                pointLayer = [weak_self drawPointToPolyPoint:targetPoint clolor:weak_self.lineInflexionColor];
            }
            
            [weak_self.shaperLayer addSublayer:pointLayer];
        }
        
    }];
    
    CGFloat faceViewW = maxX - minX + weak_self.linWidth*2.f ;
    CGFloat faceViewH = maxY - minY + weak_self.linWidth*2.f;
    minX = minX - weak_self.linWidth;
    minY = minY - weak_self.linWidth;
    self.faceView.frame = CGRectMake(minX, minY, faceViewW, faceViewH);
    NSMutableArray *temparray = [NSMutableArray new];
    for (NSString *pointSring in _path) {
        CGPoint point = CGPointFromString(pointSring);
        CGPoint converPoint = [self.parentView convertPoint:point toView:self.faceView];
        NSString *converPointStr = NSStringFromCGPoint(converPoint);
        [temparray addObject:converPointStr];
    }
    
    _convertPoints = temparray;
    
    if (_titleString) {
        [self.titleLabel sizeToFit];
        CGPoint point = CGPointFromString(points[0]);
        if (points.count%2 == 0) {
            CGPoint endPoint = CGPointFromString(points[points.count/2]);
            CGPoint startPoint = CGPointFromString(points[points.count/2 - 1]);
            point = CGPointMake((startPoint.x + endPoint.x)/2.f, (startPoint.y + endPoint.y)/2.f);
        } else {
            point = CGPointFromString(points[points.count/2]);
        }
        
        _convertPoint = [self.parentView convertPoint:point toView:self.faceView];
        self.titleLabel.center = point;
    }
    
    _shaperLayer.path      = _facePath.CGPath;
}

- (RMDrawShapeLayer *)drawPointToPolyPoint:(CGPoint)point clolor:(UIColor *)color{
    
    UIColor *tempColor = color ? color : [UIColor blueColor];
    CGFloat radius = self.linPointRadius ? self.linPointRadius : 1.f;
    
    float x = point.x;
    float y = point.y;
    
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(0, 0) radius:radius startAngle:(0) endAngle:(M_PI*2) clockwise:YES];
    RMDrawShapeLayer *circleLayer = [RMDrawShapeLayer layer];
    circleLayer.position = CGPointMake(x, y);
    circleLayer.strokeColor = tempColor.CGColor;
    circleLayer.fillColor   = tempColor.CGColor;
    circleLayer.lineWidth   = 0.000001f;
    circleLayer.path = circlePath.CGPath;
    return circleLayer;
}




- (void)changeCirecleCenterPoint:(CGPoint)centerPoint radius:(CGFloat)radius
{
    if (self.tooltype != RMDrawToolTypeCircle) { return ; }
    
    CGFloat faceVieX = centerPoint.x - radius;
    CGFloat faceVieY = centerPoint.y - radius;
    CGFloat faceViewWH = radius*2.f;
    _radius = radius;
    _centerPoint = centerPoint;
    self.faceView.frame = CGRectMake(faceVieX, faceVieY, faceViewWH, faceViewWH);
    
    _facePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(faceViewWH/2.f, faceViewWH/2.f) radius:radius startAngle:0.0 endAngle:M_PI*2 clockwise:YES];
    _shaperLayer.path      = _facePath.CGPath;
    
    if (_titleString) {
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(faceViewWH/2.f + faceVieX, faceViewWH/2.f + faceVieY);
    }
}

- (void)changePointCenterPoint:(CGPoint)centerPoint
{
    if (self.tooltype != RMDrawToolTypePoint) {
        return ;
    }
    
    CGSize imageSize = _imageSize;
    if (_imageSize.height == 0 && _imageSize.width == 0) {
        imageSize =  CGSizeMake(_image.size.width/2.f, _image.size.height/2.f);
    }
    
    CGFloat faceVieX = centerPoint.x - imageSize.width/2.f;
    CGFloat faceVieY = centerPoint.y - imageSize.height/2.f;
    self.faceView.frame = CGRectMake(faceVieX, faceVieY, imageSize.width, imageSize.height);
    
    if (_titleString) {
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(centerPoint.x, centerPoint.y + self.titleLabel.frame.size.height/2.f + imageSize.height/2.f + 5.f);
    }
    
}

- (void)changePointCenterPoint:(CGPoint)centerPoint rotate:(CGFloat)rotate
{
    if (self.tooltype != RMDrawToolTypePoint) {
        return ;
    }
    
    CGSize imageSize = _imageSize;
    if (_imageSize.height == 0 && _imageSize.width == 0) {
        imageSize =  CGSizeMake(_image.size.width/2.f, _image.size.height/2.f);
    }
    
    CGFloat faceVieX = centerPoint.x - imageSize.width/2.f;
    CGFloat faceVieY = centerPoint.y - imageSize.height/2.f;
    self.faceView.frame = CGRectMake(faceVieX, faceVieY, imageSize.width, imageSize.height);
    
    if (_titleString) {
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(centerPoint.x, centerPoint.y + self.titleLabel.frame.size.height/2.f + imageSize.height/2.f + 5.f);
    }

    self.faceView.transform             = CGAffineTransformIdentity;
    self.faceView.layer.anchorPoint      = CGPointMake(0.5, 0.5);
    // 设置图片选择角度        
    [self.faceView setTransform:CGAffineTransformMakeRotation(rotate/180.0*M_PI)];
    [self.faceView sizeToFit];


}

- (void)setFaceColor:(UIColor *)faceColor
{
    _faceColor = faceColor;
    self.faceView.backgroundColor = _faceColor;
    self.shaperLayer.strokeColor  = _faceColor.CGColor;
}

- (void)pointimageclick:(UIButton *)button
{
    if (_toolClick) {
        kWeakSelf(weak_self);
        _toolClick(weak_self);
    }
}

- (void)toolViewClick:(UITapGestureRecognizer *)tapGesture
{
    if (_toolClick) {
        kWeakSelf(weak_self);
        _toolClick(weak_self);
    }
}

- (void)setIsAllowClick:(BOOL)isAllowClick
{
    _isAllowClick = isAllowClick;
    self.faceView.userInteractionEnabled = _isAllowClick;
}

- (void)setIsHidden:(BOOL)isHidden
{
    _isHidden = isHidden;
    self.faceView.hidden = _isHidden;
}

- (void)setIsShowLineInflexion:(BOOL)isShowLineInflexion
{
    if (self.tooltype != RMDrawToolTypeLine) {
        return ;
    }
    
    _isShowLineInflexion = isShowLineInflexion;
    if (self.isShowLineInflexion) {
        self.faceView.layer.mask   = nil;
        [self.faceView.layer addSublayer:self.shaperLayer];
        self.faceView.backgroundColor = [UIColor clearColor];
    } else {
        self.faceView.layer.mask = self.shaperLayer;
        self.faceView.backgroundColor = self.faceColor ? self.faceColor : [UIColor whiteColor];
    }
    [self changeLineWithPoints:_path];
}

- (void)setLineTerminalPointColor:(UIColor *)lineTerminalPointColor {
    if (self.tooltype != RMDrawToolTypeLine) {
        return ;
    }
    _lineTerminalPointColor = lineTerminalPointColor;
    [self changeLineWithPoints:_path];
}

- (void)setLineInflexionColor:(UIColor *)lineInflexionColor {
    if (self.tooltype != RMDrawToolTypeLine) {
        return ;
    }
    _lineInflexionColor = lineInflexionColor;
    [self changeLineWithPoints:_path];
}

- (void)setLinPointRadius:(CGFloat)linPointRadius {
    if (self.tooltype != RMDrawToolTypeLine) {
        return ;
    }
    _linPointRadius = linPointRadius;
    [self changeLineWithPoints:_path];
}

- (void)removeFromSuperview
{
    [self.faceView removeFromSuperview];
    [self.titleLabel removeFromSuperview];
}

- (void)setLinWidth:(CGFloat)linWidth
{
    _linWidth = linWidth;
    _shaperLayer.lineWidth = _linWidth;
    if (self.tooltype == RMDrawToolTypeLine) {
        [self changeLineWithPoints:_path];
    }
}

- (void)setTitleString:(NSString *)titleString
{
    _titleString = titleString;
    [self.parentView insertSubview:self.titleLabel aboveSubview:self.faceView];
    _titleLabel.text = titleString;
    [self updateUI];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.parentView insertSubview:self.titleLabel aboveSubview:self.faceView];
    _titleLabel.textColor = _titleColor;
    [self updateUI];
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    [self.parentView insertSubview:self.titleLabel aboveSubview:self.faceView];
    _titleLabel.font = _titleFont;
}

- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    [self updateUI];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    if (self.tooltype == RMDrawToolTypePoint && self.faceView) {
        [((UIButton *)self.faceView) setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    [self updateUI];
}

- (void)setLabelHidden:(BOOL)labelHidden
{
    _labelHidden = labelHidden;
    _titleLabel.hidden = _labelHidden;
}

- (void)setAllowMove:(BOOL)allowMove {
    _allowMove = allowMove;
    if (self.faceView) {
        [self.faceView setRm_allowMove:_allowMove];
    }
    [self.faceView setRm_allowMove:allowMove];
}

- (void)updateUI
{
    if (self.tooltype == RMDrawToolTypeFace) {
        [self changeFaceWithPoints:self.path];
    } else if (self.tooltype == RMDrawToolTypeLine) {
        [self changeLineWithPoints:self.path];
    } else if (self.tooltype == RMDrawToolTypeCircle) {
        [self changeCirecleCenterPoint:self.centerPoint radius:self.radius];
    } else if (self.tooltype == RMDrawToolTypePoint) {
        [self changePointCenterPoint:self.centerPoint];
    }
}

- (BOOL)rm_drawViewIsResponsePoint:(CGPoint)point
{
    if (_tooltype == RMDrawToolTypeFace || _tooltype == RMDrawToolTypeCircle) {
        if (![_facePath containsPoint:point]) { return NO; }
    }
    
    if (_tooltype == RMDrawToolTypeLine) {
        point = [self.faceView convertPoint:point toView:self.parentView];
        BOOL isInLine = [RMDrawPointJudge rm_point:point inLine:_path space:30];
        if (!isInLine) {
            return NO;
        }
    }
    return YES;
}

- (void)rm_drawButtonmoveEvent {
    if (_titleString) {
        [self.titleLabel sizeToFit];
        self.titleLabel.center = CGPointMake(self.faceView.center.x, self.faceView.center.y + self.titleLabel.frame.size.height/2.f + self.faceView.frame.size.height/2.f + 5.f);
    }
}

- (void)rm_drawViewMoveEvent
{
    if (!_titleString) return;
    
    [self.titleLabel sizeToFit];
    
    if (self.tooltype == RMDrawToolTypeFace) {
        self.titleLabel.center = self.faceView.center;
    } else if (self.tooltype == RMDrawToolTypeLine) {
        
        CGPoint newCenterPoint = CGPointMake(self.faceView.frame.origin.x + _convertPoint.x, self.faceView.frame.origin.y+_convertPoint.y);
        
        NSMutableArray *tempArray = [NSMutableArray new];
        for (NSString *pointStr in _convertPoints) {
            CGPoint tempPoint = CGPointFromString(pointStr);
            tempPoint =  CGPointMake(self.faceView.frame.origin.x + tempPoint.x, self.faceView.frame.origin.y+tempPoint.y);
            NSString *converPointStr = NSStringFromCGPoint(tempPoint);
            [tempArray addObject:converPointStr];
        }
        _path = tempArray;
        self.titleLabel.center = newCenterPoint;
        
    } else if (self.tooltype == RMDrawToolTypeCircle) {
        self.titleLabel.center = self.faceView.center;
    }
}

@end
