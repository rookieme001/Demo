//
//  ViewController.m
//  AlgorithmDemo
//
//  Created by whf on 1/22/21.
//

#import "ViewController.h"
#import "SortAlgorithmFun.h"
#import <objc/runtime.h>
#import <malloc/malloc.h>
#import "TtreeManger.h"
#import "AVLTree.h"
typedef void(^SortBlock)(void);
//Definition for singly-linked list.
struct ListNode {
    int val;
    ListNode *next;
    ListNode() : val(0), next(nullptr) {}
    ListNode(int x) : val(x), next(nullptr) {}
    ListNode(int x, ListNode *next) : val(x), next(next) {}
};



@interface Person : NSObject

@end

@implementation Person
@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [TtreeManger test];
    // Do any additional setup after loading the view.
//    int count = 6;
//    NSMutableArray *array = [self createArrayWithCount:count minVaule:0 maxVaule:count];
    
//    __block NSMutableArray *array1 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array2 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array3 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array4 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array5 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array6 = [NSMutableArray arrayWithArray:array];
//
//    // 选择排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun selectSortArray:array1 elementCount:count left:0 right:count-1];
//        NSLog(@"selectSortArray:%@",array1);
//    }];
//
//    // 插入排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun insertSortArray:array2 elementCount:count left:0 right:count-1];
//        NSLog(@"insertSortArray:%@",array2);
//    }];
//
//    // 希尔排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun shellSortArray:array3 elementCount:count left:0 right:count-1];
//        NSLog(@"insertSortArray:%@",array3);
//    }];
//
//    // 归并排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun mergeSortArray:array4 elementCount:count left:0 right:count-1];
//        NSLog(@"mergeSortArray:%@",array4);
//    }];
//
//    // 快速排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun quickSortArray:array5 elementCount:count left:0 right:count-1];
//        NSLog(@"mergeSortArray:%@",array5);
//    }];
//
//    // 3路快排排序
//    [self testWithBlock:^{
//        [SortAlgorithmFun quick3waySortArray:array6 elementCount:count left:0 right:count-1];
//        NSLog(@"mergeSortArray:%@",array6);
//    }];
    
//    9 8 7 6 5 4 3
    
    // TODO：计算逆序对（归并）
//    __block NSMutableArray *array7 = [NSMutableArray arrayWithArray:array];
//    __block NSMutableArray *array8 = [NSMutableArray arrayWithArray:array];
//    [self testWithBlock:^{
//       int num = [SortAlgorithmFun inverseSelectArray:array7 elementCount:count left:0 right:count-1];
//        NSLog(@"逆序对:%d",num);
//    }];
//
//    [self testWithBlock:^{
//       int num = [SortAlgorithmFun inverseMergeArray:array8 elementCount:count left:0 right:count-1];
//        NSLog(@"逆序对:%d",num);
//    }];
    
    
    // TODO：第n大袁术（归并）
    [AVLTree test];
}


//int majorityElement(int* nums, int numsSize){
//
//}

- (void)test {
    Person *test = [[Person alloc] init];
    NSLog(@"%p-%p-%p",test,[NSObject class],objc_getMetaClass(object_getClassName([NSObject class])));
    NSLog(@"size:%d",[test isKindOfClass:[NSObject class]]);
    NSLog(@"member:%d",[[Person class] isKindOfClass:objc_getMetaClass(object_getClassName([NSObject class]))]);
//    NSLog(@"objc对象实际需要的内存大小: %zd", class_getInstanceSize([test class]));
//    NSLog(@"objc对象实际分配的内存大小: %zd", malloc_size((__bridge const void *)(test)));
}

//- (ListNode *)addTwoNumbers:(ListNode*)l1 l2:(ListNode*)l2 {
//
//}

/// 计算代码块执行时长函数
/// @param block 放入代码块
- (void)testWithBlock:(SortBlock)block {
    double lastTime = CFAbsoluteTimeGetCurrent();
    if (block) block();
    double curTime = CFAbsoluteTimeGetCurrent();
    NSLog(@"执行代码块耗时: %f ms", (curTime - lastTime) * 1000);
 
}

/// 创建随机数组
/// @param count 元素数量
/// @param minVaule 数组元素最小值
/// @param maxVaule 数组元素最大值
- (NSMutableArray *)createArrayWithCount:(int)count minVaule:(int)minVaule maxVaule:(int)maxVaule {
    
    int tempMinVaule = minVaule;
    int tempMaxVaule = maxVaule;
    
    NSMutableArray *arr = [NSMutableArray new];
    if (tempMinVaule == tempMaxVaule ) {
        for (int i = 0; i < count ; i++) {
            int vaule = tempMinVaule;
            [arr addObject:[NSString stringWithFormat:@"%d",vaule]];
        }
    } else if (tempMinVaule > tempMaxVaule) {
        int margin = tempMinVaule - tempMaxVaule + 1;
        for (int i = 0; i < count ; i++) {
            int vaule = arc4random() % margin + tempMaxVaule;
            [arr addObject:[NSString stringWithFormat:@"%d",vaule]];
        }
    } else {
        int margin = tempMaxVaule - tempMinVaule + 1;
        for (int i = 0; i < count ; i++) {
            int vaule = arc4random() % margin + tempMinVaule;
            [arr addObject:[NSString stringWithFormat:@"%d",vaule]];
        }
    }
    NSLog(@"createArray:%@",arr);
    return arr;
}


@end
