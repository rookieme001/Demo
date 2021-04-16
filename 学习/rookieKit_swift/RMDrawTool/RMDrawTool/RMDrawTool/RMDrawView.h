//
//  RMDrawView.h
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/19.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, RMDrawToolType) {
    RMDrawToolTypeLine,
    RMDrawToolTypeCircle,
    RMDrawToolTypeFace,
    RMDrawToolTypePoint,
};
NS_ASSUME_NONNULL_BEGIN

@protocol RMDrawViewDelegate <NSObject>
//@optional
- (BOOL)rm_drawViewIsResponsePoint:(CGPoint)point;

- (void)rm_drawViewMoveEvent;

@end

@interface RMDrawView : UIView
@property (nonatomic, weak) id<RMDrawViewDelegate> delegate;
@property (nonatomic, assign) RMDrawToolType type;

/**
 是否允许任意移动
 */
@property (nonatomic, assign) BOOL rm_allowMove;
@end

NS_ASSUME_NONNULL_END
