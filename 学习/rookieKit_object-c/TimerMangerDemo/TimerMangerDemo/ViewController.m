//
//  ViewController.m
//  TimerMangerDemo
//
//  Created by Rookieme on 2019/4/8.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMSingleTimer.h"
//#import "RMTimerManger.h"
#import "NSTimer+RMWeakTimer.h"
@interface ViewController ()
@property (nonatomic, assign) NSInteger timeCount;

@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 40)];
    button1.backgroundColor = [UIColor orangeColor];
    [button1 setTitle:@"启动定时器" forState:UIControlStateNormal];
    button1.tag = 0;
    [button1 addTarget:self action:@selector(button1Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button1];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(100, 150, 100, 40)];
    button3.backgroundColor = [UIColor orangeColor];
    [button3 setTitle:@"跳转页面" forState:UIControlStateNormal];
    button3.tag = 0;
    [button3 addTarget:self action:@selector(test3) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button3];
    
    _label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 335.f, 150)];
    _label1.font = [UIFont systemFontOfSize:14.f];
    _label1.numberOfLines = 0;
    _label1.textColor = [UIColor purpleColor];
    [self.view addSubview:_label1];
    
    _label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, 335, 150)];
    _label2.font = [UIFont systemFontOfSize:14.f];
    _label2.numberOfLines = 0;
    _label2.textColor = [UIColor blueColor];
    [self.view addSubview:_label2];

    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 600, 100, 40)];
    button2.backgroundColor = [UIColor blueColor];
    [button2 setTitle:@"终止定时器" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button2];
}

- (void)button1Click {
//    [[RMSingleTimer shareInstance] addObserver:self name:@"监听事件key-异步串行队列" timeInterval:2.f action:@selector(test:)];
//
//    [[RMSingleTimer shareInstance] addObserver:self name:@"监听事件key-未设置队列，默认主队列" timeInterval:5.f action:@selector(test2:)];
    for (int index = 0; index < 500; index++) {
        [[RMSingleTimer shareInstance] addObserver:self name:[NSString stringWithFormat:@"hashKey:%d",index] timeInterval:0.1f action:@selector(test3)];
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(test3) userInfo:nil repeats:YES];
//        [[RMTimerManger shareInstance] addObserver:self name:[NSString stringWithFormat:@"hashKey:%d",index] timeInterval:0.1f userInfo:nil action:@selector(test3)];
//        NSTimer *timer = [NSTimer rm_timerWithTimeInterval:0.1f target:self selector:@selector(test3) userInfo:nil repeats:YES queue:dispatch_get_main_queue()];
    }
}

- (void)button2Click {
    [[RMSingleTimer shareInstance] stop];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

- (void)test:(NSDictionary *)userInfo {
    __weak __typeof(&*self) weak_self = self;
    static int index = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        weak_self.label1.text = [NSString stringWithFormat:@"repeatTime:%d次",index];
    });
    
    index++;
//    NSLog(@"%@",[NSString stringWithFormat:@"%@\nrepeatTime:%@\ntimeInterval:%@\nactionName:%@\nname:%@\nqueue:%@",self.title,userInfo.allValues[0],userInfo.allValues[1],userInfo.allValues[2],userInfo.allValues[3],userInfo.allValues[4]]);
}

- (void)test2:(NSDictionary *)userInfo {
    static int index = 0;
    _label2.text = [NSString stringWithFormat:@"repeatTime:%d次",index];
    index++;
//    NSLog(@"%@",[NSString stringWithFormat:@"%@\nrepeatTime:%@\ntimeInterval:%@\nactionName:%@\nname:%@\nqueue:%@",self.title,userInfo.allValues[0],userInfo.allValues[1],userInfo.allValues[2],userInfo.allValues[3],userInfo.allValues[4]]);
}

- (void)test3 {
    NSLog(@"test");
//    ViewController *vc = [[ViewController alloc] init];
//    vc.title = @"TEST";
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc {
    [[RMSingleTimer shareInstance] removeObserver:self];
}

@end
