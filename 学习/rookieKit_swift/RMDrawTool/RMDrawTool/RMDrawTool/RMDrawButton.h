//
//  RMDrawButton.h
//  RMDrawDemo
//
//  Created by 韦海峰 on 2018/11/27.
//  Copyright © 2018 sepeak. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RMDrawButtonDelegate <NSObject>
- (void)rm_drawButtonmoveEvent;
@end

@interface RMDrawButton : UIButton

@property (nonatomic, weak) id<RMDrawButtonDelegate> delegate;

/**
 是否允许任意移动
 */
@property (nonatomic, assign) BOOL rm_allowMove;
@end

NS_ASSUME_NONNULL_END
