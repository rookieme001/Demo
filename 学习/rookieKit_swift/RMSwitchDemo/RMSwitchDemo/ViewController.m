//
//  ViewController.m
//  RMSwitchDemo
//
//  Created by Rookieme on 2018/12/28.
//  Copyright © 2018 Rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMSwitch/RMSwitch.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//     Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    RMSwitch *rmswitch = [[RMSwitch alloc] initWithFrame:CGRectMake(100, 100, 30, 10)];
    rmswitch.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:rmswitch];
}


@end
