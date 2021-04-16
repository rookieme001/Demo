//
//  ViewController.m
//  RMDrawTool
//
//  Created by Rookieme on 2018/12/20.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "ViewController.h"
#import "RMDrawTool.h"
@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *lineTools;
@property (nonatomic, strong) RMDrawTool *faceTool;
@property (nonatomic, strong) RMDrawTool *pointTool;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.rm_isParentView = YES;
    [self drawPoint];
    [self drawLine];
    [self drawFace];
    
}

- (void)drawFace {
    CGPoint point1 = CGPointMake(10, 10);
    CGPoint point2 = CGPointMake(10, 540);
    CGPoint point3 = CGPointMake(270, 300);
    
    NSArray *points = @[NSStringFromCGPoint(point1),NSStringFromCGPoint(point2),NSStringFromCGPoint(point3)];
    
    _faceTool = [RMDrawTool drawFaceWithPoints:points parentView:self.view];
    _faceTool.allowMove = YES;
    _faceTool.titleString = @"面";
    _faceTool.faceColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:0.6];
    _faceTool.toolClick = ^(RMDrawTool * _Nonnull tool) {
        NSLog(@"面点击");
    };
    
}

- (void)drawLine {
    _lineTools = [NSMutableArray new];
    for (NSInteger index = 0; index < 5; index++) {
        
        
        
        CGPoint point1 = CGPointMake(arc4random()%375, arc4random()%667);
        CGPoint point2 = CGPointMake(arc4random()%375, arc4random()%667);
        CGPoint point3 = CGPointMake(arc4random()%375, arc4random()%667);
        
        NSArray *points = @[NSStringFromCGPoint(point1),NSStringFromCGPoint(point2),NSStringFromCGPoint(point3)];
        
        RMDrawTool *_lineTool = [RMDrawTool drawLineWithPoints:points parentView:self.view];
        _lineTool.allowMove = YES;
        _lineTool.faceColor = [UIColor orangeColor];
        _lineTool.linWidth = 2.f;
        _lineTool.titleString = [NSString stringWithFormat:@"线:%ld",index];
        _lineTool.toolClick = ^(RMDrawTool * _Nonnull tool) {
            NSLog(@"线点击");
        };
        [_lineTools addObject:_lineTool];
    }
    
    
    
   
    
}

- (void)drawPoint {

    CGPoint point = CGPointMake(100, 220);
    
    _pointTool = [RMDrawTool drawPointWithCenterPoint:point image:[UIImage imageNamed:@""] parentView:self.view];
    _pointTool.allowMove = YES;
    _pointTool.imageSize = CGSizeMake(20, 20);
    _pointTool.faceColor = [UIColor orangeColor];
    _pointTool.titleString = @"点";
    _pointTool.toolClick = ^(RMDrawTool * _Nonnull tool) {
        NSLog(@"点点击");
    };
    
}


@end
