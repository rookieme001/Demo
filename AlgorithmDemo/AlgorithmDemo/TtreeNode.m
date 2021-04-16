//
//  TtreeNode.m
//  AlgorithmDemo
//
//  Created by whf on 3/12/21.
//

#import "TtreeNode.h"

@implementation TtreeNode
- (instancetype)initWihtVaule:(int)nodeVaule leftNode:(TtreeNode *)leftNode rightNode:(TtreeNode *)rightNode
{
    self = [super init];
    if (self) {
        _left = leftNode;
        _right = rightNode;
        _nodeVaule = nodeVaule;
    }
    return self;
}
@end
