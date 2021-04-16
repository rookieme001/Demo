//
//  AVLTree.h
//  AlgorithmDemo
//
//  Created by whf on 3/30/21.
//

#import <Foundation/Foundation.h>
#import "AVLTreeNode.h"
#import "MJBinaryTrees.h"
NS_ASSUME_NONNULL_BEGIN

@interface AVLTree : NSObject<MJBinaryTreeInfo>
// 根节点
@property (nonatomic, strong) AVLTreeNode *root;
// 树高
@property (nonatomic, assign) int height;
// 是否平衡
@property (nonatomic, assign) BOOL isBalanced;
// 树元素数量
@property (nonatomic, assign) int size;

+ (void)test;
@end

NS_ASSUME_NONNULL_END
