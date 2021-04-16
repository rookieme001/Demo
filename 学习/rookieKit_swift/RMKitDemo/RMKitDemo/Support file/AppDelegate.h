//
//  AppDelegate.h
//  RMKitDemo
//
//  Created by Rookieme on 2018/12/27.
//  Copyright © 2018 rookieme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

