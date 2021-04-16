//
//  ViewController.m
//  AnimationDemo
//
//  Created by whf on 1/25/21.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIView *backgroundView;

/**
 振幅A
 */
@property (nonatomic, assign) CGFloat alpha;

/**
 角速度ω
 */
@property (nonatomic, assign) CGFloat omega;

/**
 初相φ
 */
@property (nonatomic, assign) CGFloat phi;

/**
 偏距k
 */
@property (nonatomic, assign) CGFloat kappa;


/**
 移动速度
 */
@property (nonatomic, assign) CGFloat speed;

@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.backgroundView];

    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(0, 0, 375, 50);
    label.text = @"搜索指定内容";
    label.font = [UIFont systemFontOfSize:13.f];
    label.textAlignment = NSTextAlignmentCenter;
    [_backgroundView addSubview:label];

    // 创建渐变层
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = label.frame;
    
    // 渐变层颜色随机
//    gradientLayer.colors = @[(id)[self randomColor].CGColor, (id)[self randomColor].CGColor, (id)[self randomColor].CGColor];
    [self.view.layer addSublayer:gradientLayer];
    
    // mask层工作原理:按照透明度裁剪，只保留非透明部分，文字就是非透明的，因此除了文字，其他都被裁剪掉，这样就只会显示文字下面渐变层的内容，相当于留了文字的区域，让渐变层去填充文字的颜色。
    // 设置渐变层的裁剪层
    gradientLayer.mask = label.layer;
    
    // 注意:一旦把label层设置为mask层，label层就不能显示了,会直接从父层中移除，然后作为渐变层的mask层，且label层的父层会指向渐变层
    // 父层改了，坐标系也就改了，需要重新设置label的位置，才能正确的设置裁剪区域。
//    label.frame = gradientLayer.bounds;

}

- (UIBezierPath *)createSinPath
{
   UIBezierPath *wavePath = [UIBezierPath bezierPath];
   CGFloat endX = 0;
   for (CGFloat x = 0; x < self.waveWidth + 1; x += 1) {
       endX=x;
       CGFloat y = self.maxAmplitude * sinf(360.0 / _waveWidth * (x  * M_PI / 180) * self.frequency + self.phase * M_PI/ 180) + self.maxAmplitude;
       if (x == 0) {
           [wavePath moveToPoint:CGPointMake(x, y)];
       } else {
           [wavePath addLineToPoint:CGPointMake(x, y)];
       }
   }
  
   CGFloat endY = CGRectGetHeight(self.bounds) + 10;
   [wavePath addLineToPoint:CGPointMake(endX, endY)];
   [wavePath addLineToPoint:CGPointMake(0, endY)];
   
   return wavePath;
}

- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 375, 50)];
        _backgroundView.backgroundColor = [UIColor yellowColor];
    }
    return _backgroundView;
}




@end
