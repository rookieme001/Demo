//
//  AVLTreeNode.m
//  AlgorithmDemo
//
//  Created by whf on 3/30/21.
//

#import "AVLTreeNode.h"

@implementation AVLTreeNode
- (instancetype)initWihtVaule:(int)vaule {
    self = [super init];
    if (self) {
        self.height = 1;
        _num = vaule;
    }
    return self;
}

- (BOOL)campareTo:(AVLTreeNode *)node {
    return self.num > node.num;
}
@end
