//
//  Person.h
//  Runtime
//
//  Created by Rookieme on 2019/3/30.
//  Copyright © 2019 Rookieme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject {
    @public
    float height;
}

@property (nonatomic, assign) NSString *name;
@property (nonatomic, strong) NSString *key;
@end

NS_ASSUME_NONNULL_END
