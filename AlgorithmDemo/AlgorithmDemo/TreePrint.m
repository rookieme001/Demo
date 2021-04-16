//
//  TreePrint.m
//  AlgorithmDemo
//
//  Created by whf on 3/30/21.
//

#import "TreePrint.h"

@implementation TreePrint



+ (void)printTree:(AVLTreeNode *)tree {
    NSMutableArray *listArray = [NSMutableArray new];
    
    [listArray addObject:tree];
    long currentNum = listArray.count;
    NSMutableArray *lineArrays = [NSMutableArray new];
    NSMutableArray *templineArray = [NSMutableArray new];
    NSString *string = @"\n";
    while (currentNum) {
        currentNum--;
        AVLTreeNode *node = listArray.firstObject;
        [listArray removeObjectAtIndex:0];
        [templineArray addObject:node];
        if (node.left) {
            [listArray addObject:node.left];
        }
        
        if (node.right) {
            [listArray addObject:node.right];
        }
        
        string = [string stringByAppendingFormat:@" %d",node.num];
        if (currentNum == 0) {
            currentNum = listArray.count;
            string = [string stringByAppendingString:@"\n"];
            [lineArrays addObject:[NSArray arrayWithArray:templineArray]];
            [templineArray removeAllObjects];
        }
    }
   
    NSLog(@"%@",string);
    
    
//    NSLog(@"---%@",lineArrays);
}
@end
