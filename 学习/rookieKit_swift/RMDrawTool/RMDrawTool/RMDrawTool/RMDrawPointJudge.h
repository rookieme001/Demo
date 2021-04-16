//
//  RMDrawPointJudge.h
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/19.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RMDrawPointJudge : NSObject
+ (BOOL)rm_point:(CGPoint)point inLine:(NSArray *)line space:(float)space;
+ (double)rm_point:(CGPoint)point lineStartPoint:(CGPoint)startPoint lineEndPoint:(CGPoint)endPoint;
+ (NSInteger)rm_point:(CGPoint)point inPoints:(NSArray *)points space:(CGFloat)space;
@end

NS_ASSUME_NONNULL_END
