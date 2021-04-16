//
//  TtreeNode.h
//  AlgorithmDemo
//
//  Created by whf on 3/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TtreeNode : NSObject
@property (nonatomic, strong) TtreeNode *left;
@property (nonatomic, strong) TtreeNode *right;

@property (nonatomic, assign) int nodeVaule;

- (instancetype)initWihtVaule:(int)nodeVaule leftNode:(TtreeNode *)leftNode rightNode:(TtreeNode *)rightNode;
@end

NS_ASSUME_NONNULL_END
