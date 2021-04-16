//
//  ViewController.m
//  Runtime
//
//  Created by Rookieme on 2019/3/29.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "Person.h"
#import "UIView+Rookieme.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    UIView *test = [UIView alloc];
    [test printString];
  
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    Person *p = [[Person alloc] init];
    p.name = @"wei";
    p.key = @"2342";
    
    NSLog(@"%@--%@",p.name,[p valueForKey:@"key"]);
}

- (NSString *)test {
    return @"test";
}

@end
