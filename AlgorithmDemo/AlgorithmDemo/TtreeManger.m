//
//  TtreeManger.m
//  AlgorithmDemo
//
//  Created by whf on 3/12/21.
//

#import "TtreeManger.h"
#import "TtreeNode.h"
@implementation TtreeManger


+ (void)test {
    TtreeNode *node = [self creatTree:[self ceartVaules]];
    [self printTree:node];
}


+ (NSMutableArray *)ceartVaules {
    NSMutableArray *array = [NSMutableArray new];
    for (int index = 0; index < 6; index++) {
        int num = arc4random() % 100;
        [array addObject:[NSString stringWithFormat:@"%d",num]];
    }
    NSLog(@"array:---%@",array);
    return array;
}

+ (TtreeNode *)creatTree:(NSMutableArray *)array {
    if (array == nil || array.count == 0) {
        return nil;
    }
    TtreeNode *node;

    
    for (int index = 0; index < array.count; index++) {
        int nodeVaule = [array[index] intValue];
        TtreeNode *newNode = [[TtreeNode alloc] init];
        newNode.nodeVaule = nodeVaule;
        if (node) {
            [self addNewNode:newNode forTree:node];
        } else {
            node = newNode;
        }
    }
    
    return node;
}

+ (void)addNewNode:(TtreeNode *)newNode forTree:(TtreeNode *)tree {
    if (newNode.nodeVaule < tree.nodeVaule) {
        if (tree.left == nil) {
            tree.left = newNode;
        } else {
            [self addNewNode:newNode forTree:tree.left];
        }
    } else if (newNode.nodeVaule > tree.nodeVaule) {
        if (tree.right == nil) {
            tree.right = newNode;
        } else {
            [self addNewNode:newNode forTree:tree.right];
        }
    }
}

+ (void)printTree:(TtreeNode *)tree {
    
    NSLog(@"tree %d",tree.nodeVaule);
    if (tree.left) {
        [self printTree:tree.left];
    }
    
    if (tree.right) {
        [self printTree:tree.right];
    }
}

+ (void)logTree:(TtreeNode *)tree {
    
}

@end
