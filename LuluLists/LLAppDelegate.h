//
//  LLAppDelegate.h
//  LuluLists
//
//  Created by Dingzhong Weng on 1/5/13.
//  Copyright (c) 2013 Dingzhong Weng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface LLAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;


extern NSString*const LLStandardFont;
extern NSString*const LLStandardPixelizedFont;


@end
