//
//  ViewController.m
//  RMCoordinateTransformDemo
//
//  Created by Rookieme on 2018/12/22.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMCoordinateTransform/RMCoordinateTransform.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    double sourceCoordinate = 120.123456789;
    
    NSString *coordinateString = [RMCoordinateTransform rm_transformCoordinate:sourceCoordinate format:RMCoordinateTransformFormatDegree precision:15];
    NSLog(@"%@",coordinateString);
    
    NSArray *array = [RMCoordinateTransform rm_interceptCoordinate:sourceCoordinate targetFormat:RMCoordinateTransformFormatDefault precision:15];
    
    for (NSString *string in array) {
        NSLog(@"%@",string);
    }
    
    double coordinate = [RMCoordinateTransform rm_getCoordinateByDegreeString:array[0] minuteString:array[1] secondString:array[2]];
    // 取double类型最大精度，用.f超过最大精度会出现误差
    NSLog(@"%@",[[NSNumber numberWithDouble:coordinate] stringValue]);
}


@end
