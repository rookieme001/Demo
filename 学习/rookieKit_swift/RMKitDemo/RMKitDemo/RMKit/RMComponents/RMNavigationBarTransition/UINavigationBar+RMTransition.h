//
//  UINavigationBar+RMTransition.h
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationBar (RMTransition)
/// 用来模仿真的navBar，配合 UINavigationController 在转场过程中存在的一条假navBar
@property(nonatomic, strong) UINavigationBar *rm_transitionNavigationBar;
@end

NS_ASSUME_NONNULL_END
