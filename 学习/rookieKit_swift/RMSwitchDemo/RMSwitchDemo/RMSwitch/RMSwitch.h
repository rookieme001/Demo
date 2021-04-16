//
//  RMSwitch.h
//  RMSwitchDemo
//
//  Created by Rookieme on 2018/12/28.
//  Copyright © 2018 Rookieme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RMSwitch : UIControl

@property(nullable, nonatomic, strong) UIColor *onTintColor;
@property(null_resettable, nonatomic, strong) UIColor *tintColor;
@property(nullable, nonatomic, strong) UIColor *thumbTintColor;

@property(nullable, nonatomic, strong) UIImage *onImage;
@property(nullable, nonatomic, strong) UIImage *offImageR;

@property(nonatomic,getter=isOn) BOOL on;

- (instancetype)initWithFrame:(CGRect)frame ;      // This class enforces a size appropriate for the control, and so the frame size is ignored.
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder;

- (void)setOn:(BOOL)on animated:(BOOL)animated; // does not send action
@end

NS_ASSUME_NONNULL_END
