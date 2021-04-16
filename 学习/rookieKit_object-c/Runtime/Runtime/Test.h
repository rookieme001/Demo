//
//  Test.h
//  Runtime
//
//  Created by Rookieme on 2019/3/29.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#include <objc/objc.h>
#include <objc/NSObjCRuntime.h>
#import <Foundation/Foundation.h>

@protocol Test
//- (instancetype)init;
//+ (instancetype)alloc OBJC_SWIFT_UNAVAILABLE("use object initializers instead");
@end

OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0)
OBJC_ROOT_CLASS
OBJC_EXPORT
@interface Test <Test>
- (void)eat;

@end
