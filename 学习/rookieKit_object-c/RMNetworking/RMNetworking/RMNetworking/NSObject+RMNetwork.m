//
//  NSObject+RMNetwork.m
//  RMNetworking
//
//  Created by rookieme on 2018/12/11.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import "NSObject+RMNetwork.h"

@implementation NSObject (RMNetwork)
- (BOOL)rm_isNotNull {
    if(self != nil && self != NULL && (NSNull *)self != [NSNull null]) {
        return YES;
    }
    return NO;
}

- (BOOL)rm_isNotEmpty {
    if ([self isKindOfClass:[NSArray class]] ||
        [self isKindOfClass:[NSMutableArray class]] ||
        [self isKindOfClass:[NSSet class]] ||
        [self isKindOfClass:[NSMutableSet class]] ||
        [self isKindOfClass:[NSDictionary class]] ||
        [self isKindOfClass:[NSMutableDictionary class]]) {
        if(self != nil &&
           self != NULL &&
           (NSNull *)self != [NSNull null] &&
           [self respondsToSelector:@selector(count)] &&
           [self performSelector:@selector(count) withObject:nil] > 0) {
            return YES;
        }
        return NO;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if (self != nil &&
            self != NULL &&
            (NSNull *)self != [NSNull null] &&
            [self respondsToSelector:@selector(length)] && [(NSString *)self length] > 0) {
            return YES;
        }
        return NO;
    }
    
    
    if(self !=nil && self != NULL && (NSNull *)self != [NSNull null]) {
        return YES;
    }
    return NO;
}

@end
