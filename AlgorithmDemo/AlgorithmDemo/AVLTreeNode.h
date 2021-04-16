//
//  AVLTreeNode.h
//  AlgorithmDemo
//
//  Created by whf on 3/30/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVLTreeNode : NSObject
@property (nonatomic, strong) AVLTreeNode *left;
@property (nonatomic, strong) AVLTreeNode *right;
@property (nonatomic, strong) AVLTreeNode *parent;
// 树的值
@property (nonatomic, assign) int num;

@property (nonatomic, assign) int height;

- (instancetype)initWihtVaule:(int)vaule;

- (BOOL)campareTo:(AVLTreeNode *)node;

@end

NS_ASSUME_NONNULL_END
