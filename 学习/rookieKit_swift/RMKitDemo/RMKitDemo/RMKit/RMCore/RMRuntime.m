//
//  RMRuntime.m
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "RMRuntime.h"

@implementation RMRuntime

+ (BOOL)rm_exchangeInstanceMethod:(Class)anClass originSelector:(SEL)originSelector newSelector:(SEL)newSelector {
    return [self rm_exchangeInstanceMethodFromClass:anClass originSelector:originSelector toClass:anClass newSelector:newSelector];
}

+ (BOOL)rm_exchangeInstanceMethodFromClass:(Class)fromClass originSelector:(SEL)originSelector toClass:(Class)toClass newSelector:(SEL)newSelector {
    if (!fromClass || !toClass) {
        return NO;
    }
    
    Method oriMethod = class_getInstanceMethod(fromClass, originSelector);
    Method newMethod = class_getInstanceMethod(toClass, newSelector);
    if (!newMethod) {
        return NO;
    }
    
    BOOL didAddMethod = class_addMethod(fromClass, originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        // 如果 class_addMethod 成功了，说明之前 fromClass 里并不存在 originSelector，所以要用一个空的方法代替它，以避免 class_replaceMethod 后，后续 toClass 的这个方法被调用时可能会 crash
        IMP oriMethodIMP = method_getImplementation(oriMethod) ?: imp_implementationWithBlock(^(id selfObject) {});
        const char *oriMethodTypeEncoding = method_getTypeEncoding(oriMethod) ?: "v@:";
        class_replaceMethod(toClass, newSelector, oriMethodIMP, oriMethodTypeEncoding);
    } else {
        method_exchangeImplementations(oriMethod, newMethod);
    }
    return YES;
}
@end
