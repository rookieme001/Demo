//
//  SortAlgorithmFun.m
//  AlgorithmDemo
//
//  Created by whf on 1/22/21.
//

#import "SortAlgorithmFun.h"

@implementation SortAlgorithmFun
+ (void)selectSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    /* 双重for循环， n2*/
    for (int i = 0; i < elementCount; i++) {
        int iVaule = [array[i] intValue];
        for (int j = i+1; j < elementCount; j++) {
            int jVaule = [array[j] intValue];
            if (jVaule < iVaule) {
                [array exchangeObjectAtIndex:i withObjectAtIndex:j];
                iVaule = jVaule;
            }
        }
    }
}

+ (void)insertSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right{
    /* 分组排序， n2*/
    for (int i = 1; i < elementCount; i++) {
        int iVaule = [array[i] intValue];
        int index = i;
        
        for (int j = i-1; j > 0; j--) {
            int jVaule = [array[j] intValue];
            if (iVaule < jVaule) {
                [array exchangeObjectAtIndex:index withObjectAtIndex:j];
                index = j;
            } else {
                break;
            }
        }

    }
}

+ (void)shellSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    /* 分组排序， nlogn*/
    for (int group = elementCount/2; group > 0; group /= 2) {
        
        for (int j = group; j < elementCount; j++) {
            int jVaule = [array[j] intValue];
            
            for (int i = j - group; i >= 0; i -= group) {
                int iVaule = [array[i] intValue];
                if (jVaule < iVaule) {
                    [array exchangeObjectAtIndex:i+group withObjectAtIndex:i];
                } else {
                    break;
                }
            }
        }
    }
}

+ (void)mergeSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right{
    if (left >= right) {
        return;
    }
    
    int middle = (left + right) / 2;
    [self mergeSortArray:array elementCount:elementCount left:left right:middle];
    [self mergeSortArray:array elementCount:elementCount left:middle+1 right:right];
    [self mergeSort:array middle:middle left:left right:right];
}

+ (void)mergeSort:(NSMutableArray *)array middle:(int)middle left:(int)left right:(int)right {
    
    int count = right - left + 1;
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = left; i <= right; i++) {
        tempArray[i-left] = array[i];
    }
    
    int leftIndex  = left;
    int rightIndex = middle + 1;
    for (int i = left; i <= right ; i++) {
        if (leftIndex > middle) {
            array[i] = tempArray[rightIndex - left];
            rightIndex++;
        } else if (rightIndex > right) {
            array[i] = tempArray[leftIndex - left];
            leftIndex++;
        } else if ([tempArray[leftIndex - left] intValue] < [tempArray[rightIndex - left] intValue]) {
            array[i] = tempArray[leftIndex - left];
            leftIndex++;
        } else {
            array[i] = tempArray[rightIndex - left];
            rightIndex++;
        }
    }
    
}

+ (void)quickSortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    if (left >= right || left < 0) {
        return;
    }
    
    int p = [self quickSort:array elementCount:elementCount left:left right:right];
    [self quickSortArray:array elementCount:elementCount left:left right:p-1];
    [self quickSortArray:array elementCount:elementCount left:p+1 right:right];
}

+ (int)quickSort:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    
    int tempIndex = arc4random() % (right - left + 1) + left;
    [array exchangeObjectAtIndex:tempIndex withObjectAtIndex:left];
    int eVaule = [array[left] intValue];
    
    int eIndex = left;
    for (int i = left+1; i <= right; i++) {
        int iVaule = [array[i] intValue];
        if (iVaule < eVaule) {
            [array exchangeObjectAtIndex:++eIndex withObjectAtIndex:i];
        }
    }
    [array exchangeObjectAtIndex:eIndex withObjectAtIndex:left];
    return eIndex;
}

#pragma mark - TODO 双路快排，左右2路均分中间值（小于等于中间值、大于等于中间值）
+ (void)quick2waySortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    
}

+ (void)quick3waySortArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    
    if (left >= right || left < 0) {
        return;
    }
    
    int tempIndex = arc4random() % (right - left + 1) + left;
    int eVaule = [array[tempIndex] intValue];
    [array exchangeObjectAtIndex:tempIndex withObjectAtIndex:left];
    
    int lt = left, gt = right;
    int i = left+1;
    
    while (i <= gt) {
        int iVaule = [array[i] intValue];
        if (iVaule < eVaule) {
            [array exchangeObjectAtIndex:++lt withObjectAtIndex:i];
            i++;
        } else if (iVaule == eVaule) {
            i++;
        } else if (iVaule > eVaule) {
            [array exchangeObjectAtIndex:gt-- withObjectAtIndex:i];
        }
    }
    [array exchangeObjectAtIndex:lt withObjectAtIndex:left];
    
    [self quick3waySortArray:array elementCount:elementCount left:left right:lt-1];
    [self quick3waySortArray:array elementCount:elementCount left:gt right:right];
}

+ (int)inverseSelectArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    int tempNum = 0;
    for (int i = 0; i < elementCount; i++) {
        int iVaule = [array[i] intValue];
        
        for (int j = i+1; j < elementCount; j++) {
            int jVaule = [array[j] intValue];
            if (jVaule < iVaule) {
                tempNum++;
            }
        }
        
    }
    return tempNum;
}

+ (int)inverseMergeArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right {
    return [self inversePairsArray:array elementCount:elementCount left:left right:right num:0];
}

+ (int)inversePairsArray:(NSMutableArray *)array elementCount:(int)elementCount left:(int)left right:(int)right num:(int)num {
    if (left >= right) {
        return num;
    }
    
    int middle = left + (right - left) / 2;
    int tempNum = [self inversePairsArray:array elementCount:elementCount left:left right:middle num:num];
    tempNum = [self inversePairsArray:array elementCount:elementCount left:middle+1 right:right num:tempNum];
    tempNum = [self inversePairs:array middle:middle left:left right:right num:tempNum];
    return tempNum;
}

+ (int)inversePairs:(NSMutableArray *)array middle:(int)middle left:(int)left right:(int)right num:(int)num{
    
    int count = right - left + 1;
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = left; i <= right; i++) {
        tempArray[i-left] = array[i];
    }
    
    int tempNum = num;
    
    int leftIndex  = left;
    int rightIndex = middle + 1;
    for (int i = left; i <= right ; i++) {
        if (leftIndex > middle) {
            array[i] = tempArray[rightIndex - left];
            rightIndex++;
        } else if (rightIndex > right) {
            array[i] = tempArray[leftIndex - left];
            leftIndex++;
            
            tempNum += middle - left + 1;
        } else if ([tempArray[leftIndex - left] intValue] <= [tempArray[rightIndex - left] intValue]) {
            array[i] = tempArray[leftIndex - left];
            leftIndex++;
        } else {
            array[i] = tempArray[rightIndex - left];

            tempNum += (rightIndex - middle + 1);
            rightIndex++;
        }
    }
    
    return tempNum;
}
    
// TODO：第n大袁术（归并）

@end
