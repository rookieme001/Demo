//
//  RMDrawPointJudge.m
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/19.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import "RMDrawPointJudge.h"
#define RM_WeakSelf(weak_self) __weak __typeof(&*self) weak_self = self
@implementation RMDrawPointJudge

/**
 判断点是否在线上

 @param point 点
 @param line  线（点数组）
 @param space 偏差
 @return      是否在线上
 */
+ (BOOL)rm_point:(CGPoint)point inLine:(NSArray *)line space:(float)space
{
    __block float reactSpace = space + 1.0;
    RM_WeakSelf(weak_self);
    [line enumerateObjectsUsingBlock:^(NSString *pointString, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx > 0) {
            NSString *startString = line[idx-1];
            CGPoint startPoint = CGPointFromString(startString);
            CGPoint endPoint   = CGPointFromString(pointString);
            float tempSpace = [weak_self rm_point:point lineStartPoint:startPoint lineEndPoint:endPoint];
            
            if (tempSpace <= space) {
                reactSpace = tempSpace;
                *stop = YES;
            }
        }
    }];
    
    if (reactSpace <= space) {
        return YES;
    }
    
    return NO;
}


/**
 判读点到线的距离
 
 @param point      用户点击的屏幕坐标
 @param startPoint 两点连线起点坐标
 @param endPoint   两点连线终点坐标
 @return           点到线距离
 */
+ (double)rm_point:(CGPoint)point lineStartPoint:(CGPoint)startPoint lineEndPoint:(CGPoint)endPoint {
    
    double space = 0.0;
    double a,b,c;
    
    a = [self lineSpaceWithx1:startPoint.x y1:startPoint.y x2:endPoint.x y2:endPoint.y]; // 线段的长度
    b = [self lineSpaceWithx1:startPoint.x y1:startPoint.y x2:(int)point.x y2:(int)point.y]; // (x1,y1)到点的距离
    c = [self lineSpaceWithx1:endPoint.x y1:endPoint.y x2:(int)point.x y2:(int)point.y]; // (x2,y2)到点的距离
    
    if (c <= 0.000001 || b <= 0.000001) {
        space = 0;
        return space;
    }
    if (a <= 0.000001) {
        space = b;
        return space;
    }
    if (c * c >= a * a + b * b) {
        space = b;
        return space;
    }
    if (b * b >= a * a + c * c) {
        space = c;
        return space;
    }
    
    double p = (a + b + c) / 2;// 半周长
    double s = sqrt(p * (p - a) * (p - b) * (p - c));// 海伦公式求面积
    space = 2 * s / a;// 返回点到线的距离（利用三角形面积公式求高）
    return space;
}

+(double)lineSpaceWithx1:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2{
    double lineLength = 0.0;
    lineLength = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
    return lineLength;
}


/**
 判断点是否在点集合内

 @param point  点
 @param points 点集合
 @param space  偏差范围
 @return       点索引（未找到返回-1）
 */
+ (NSInteger)rm_point:(CGPoint)point inPoints:(NSArray *)points space:(CGFloat)space
{
    for (NSInteger index = 0; index < points.count; index++)
    {
        CGPoint arrayPoint = CGPointFromString(points[index]);
        // 判断是否点是否已包含相同
        if (((arrayPoint.x-space) <= point.x &&
             point.x <= (arrayPoint.x+space)) &&
            ((arrayPoint.y-space) <= point.y &&
             point.y <= (arrayPoint.y+space)))
        {
            return index;
        }
    }
    return -1;
}
@end
