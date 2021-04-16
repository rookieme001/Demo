//
//  AVLTree.m
//  AlgorithmDemo
//
//  Created by whf on 3/30/21.
//

#import "AVLTree.h"
#import "TreePrint.h"
@implementation AVLTree

+ (void)test {
    int num = 1000;
    AVLTree *tree = [[AVLTree alloc] init];
//    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:@[@"1201",@"1533",@"1135",@"1463"]];
//    for (NSString *vaule in tempArray) {
//        int num = [vaule intValue];
//        tree.root = [tree addNode:tree.root vaule:num];
//        NSLog(@"%d",num);
//        [MJBinaryTrees println:tree];
//    }
    for (int index = 0; index < 60; index++) {
        int vaule = arc4random()%num + num;
        tree.root = [tree addNode:tree.root vaule:vaule];
        NSLog(@"%d",vaule);
        sleep(1  );
        [MJBinaryTrees println:tree];
    }
    
//    [TreePrint printTree:tree.root];
//    [MJBinaryTrees println:tree];
}

// 获取平衡因子
- (int)getBalanceFactor:(AVLTreeNode *)node {
    if (node == nil) {
        return 0;
    }
    return [self getNodeHeight:node.left] - [self getNodeHeight:node.right];
}

- (int)getNodeHeight:(AVLTreeNode *)node {
    if(node == nil){
        return 0;
    }
    return MAX([self getNodeHeight:node.left], [self getNodeHeight:node.right]) + 1;
}

- (BOOL)isBalanced {
    return [self isBalanced:_root];
}

//判断树是否为平衡二叉树
- (BOOL)isBalanced:(AVLTreeNode *)node {
    if (node == nil) {
        return YES;
    }
    int balanceFactory = abs([self getBalanceFactor:node]);
    if (balanceFactory > 1) {
        return NO;
    }
    
    return [self isBalanced:node.left] && [self isBalanced:node.right];
}

// 旋转
// LL(右旋)
- (AVLTreeNode *)rightRotate:(AVLTreeNode *)node {
    AVLTreeNode *originalLeftSub = node.left;
    AVLTreeNode *originalLeftSubR = originalLeftSub.right;
    
    originalLeftSub.right = node;
    node.left = originalLeftSubR;

    originalLeftSub.height = MAX([self getNodeHeight:originalLeftSub.left], [self getNodeHeight:originalLeftSub.right]) + 1;
    node.height = MAX([self getNodeHeight:node.left], [self getNodeHeight:node.right]) + 1;
    return originalLeftSub;
}
// RR (左旋)
- (AVLTreeNode *)leftRotate:(AVLTreeNode *)node {
    AVLTreeNode *originalRightSub = node.right;
    AVLTreeNode *originalRighSubL = originalRightSub.left;
    
    originalRightSub.left = node;
    node.right = originalRighSubL;

    originalRightSub.height = MAX([self getNodeHeight:originalRightSub.left], [self getNodeHeight:originalRightSub.right]) + 1;
    node.height = MAX([self getNodeHeight:node.left], [self getNodeHeight:node.right]) + 1;
    return originalRightSub;
}

// LR (先左旋，再右旋)
// RL (先右旋，再左旋)


- (AVLTreeNode *)addNode:(AVLTreeNode *)root vaule:(int)vaule {
    if (root == nil) {
        _size ++;
        AVLTreeNode *node = [[AVLTreeNode alloc] initWihtVaule:vaule];
        return node;
    }
    
    // 添加节点
    if (vaule < root.num) {
        root.left = [self addNode:root.left vaule:vaule];
    } else if (vaule > root.num) {
        root.right = [self addNode:root.right vaule:vaule];
    }
    
    // 更新height
    root.height = 1 + MAX([self getNodeHeight:root.left], [self getNodeHeight:root.right]);
    // 计算平衡因子
    int balanceFactory = [self getBalanceFactor:root];
    
    if (balanceFactory > 1 && [self getBalanceFactor:root.left] > 0) {
        // (ll)右旋
        return [self rightRotate:root];
    }
    
    if (balanceFactory < -1 && [self getBalanceFactor:root.right] < 0) {
        // (RR)左旋
        return [self leftRotate:root];
    }
    
    if (balanceFactory > 1 && [self getBalanceFactor:root.left] < 0) {
        // (lR)左旋 再右旋
        root.left = [self leftRotate:root.left];
        return [self rightRotate:root];
    }
    
    if (balanceFactory < -1 && [self getBalanceFactor:root.right] > 0) {
        // (RL)右旋 再左旋
        root.right = [self rightRotate:root.right];
        return [self leftRotate:root];
    }
    
    return root;
}

//- (AVLTreeNode *)removeNode:(AVLTreeNode *)root vaule:(int)vaule {
//    
//}


#pragma mark - MJBinaryTreeInfo
- (id)left:(AVLTreeNode *)node {
    return node.left;
}

- (id)right:(AVLTreeNode *)node {
    return node.right;
}

- (id)string:(AVLTreeNode *)node {
    return [NSString stringWithFormat:@"%d",node.num];
}

- (id)root {
    return _root;
}

@end
