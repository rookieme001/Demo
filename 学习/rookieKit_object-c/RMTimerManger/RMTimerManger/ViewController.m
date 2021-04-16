//
//  ViewController.m
//  RMTimerManger
//
//  Created by Rookieme on 2019/4/19.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMTimerManger/RMTimerManger.h"

static NSString *RMTimerNameZeroPointOneSeconds = @"RMTimerNameZeroPointOneSecond";
static NSString *RMTimerNameOneSeconds          = @"RMTimerNameOneSeconds";
static NSString *RMTimerNameFiveSeconds         = @"RMTimerNameFiveSeconds";
static NSString *RMTimerNameTenSeconds          = @"RMTimerNameTenSeconds";

@interface ViewController ()
{
    BOOL isRun;
}

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
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(100, 600, 100, 40)];
    button2.backgroundColor = [UIColor blueColor];
    [button2 setTitle:@"终止定时器" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(button2Click) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:button2];
    
    
}

- (void)button1Click {
//    for (NSInteger index = 0; index < 100; index ++) {
//        NSString *name = [NSString stringWithFormat:@"hashkey%ld",(long)index];
//        [RMTimerManger timerWithName:name timeInterval:0.1 target:self selector:@selector(test:) userInfo:@{@"name":name} repeats:YES];
//
////        NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(test:) userInfo:@{@"name":name} repeats:YES];
////        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
////        [timer fire];
//    }
    
    [RMTimerManger timerWithName:RMTimerNameZeroPointOneSeconds timeInterval:0.1 target:self selector:@selector(test:) userInfo:@{@"name":RMTimerNameZeroPointOneSeconds} repeats:YES];
    
    [RMTimerManger timerWithName:RMTimerNameOneSeconds timeInterval:1.0 target:self selector:@selector(test:) userInfo:@{@"name":RMTimerNameOneSeconds} repeats:YES];
    
    [RMTimerManger timerWithName:RMTimerNameFiveSeconds timeInterval:5.0 target:self selector:@selector(test:) userInfo:@{@"name":RMTimerNameFiveSeconds} repeats:YES];
    
    [RMTimerManger timerWithName:RMTimerNameTenSeconds timeInterval:10.0 target:self selector:@selector(test:) userInfo:@{@"name":RMTimerNameTenSeconds} repeats:YES];
}

- (void)button2Click {
    [RMTimerManger invalidate];
}

- (void)test:(NSTimer *)timer {
    NSLog(@"%@",[NSString stringWithFormat:@"timeInterval:%f\ntolerance:%f\nuserInfo:%@",timer.timeInterval,timer.tolerance,timer.userInfo]);
}

- (void)test3 {
    ViewController *vc = [[ViewController alloc] init];
    vc.title = @"TEST";
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",[RMTimerManger timerMap]);
}

- (void)dealloc {
    NSLog(@"释放了--!");
}

@end
