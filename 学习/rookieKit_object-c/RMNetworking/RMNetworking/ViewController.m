//
//  ViewController.m
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMNetworkManger.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    for (int index = 0; index < 20; index ++) {
        RMNetworkManger *netService = [[RMNetworkManger alloc] init];
        netService.urlStr = @"http://api.seaweather.cn:81";
        netService.handler = @"app";
        netService.method = @"checkSmsVercode";
        [netService rm_setParamByKey:@"phone" param:@"18069412752"];
        [netService rm_setParamByKey:@"vercode" param:@"2234"];
        [netService rm_postCompletionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error == nil) {
                [self showAlertWithTitle:@"normalTest" content:@"no_error"];
            }
            else
            {
                [self showAlertWithTitle:@"normalTest" content:@"error"];
            }
        }];
    }
    
}

/**
 提示弹框
 
 @param title   弹框标题
 @param content 弹框内容
 */
- (void)showAlertWithTitle:(NSString *)title content:(NSString *)content
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    });
}

@end
