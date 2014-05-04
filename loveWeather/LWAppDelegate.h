//
//  LWAppDelegate.h
//  loveWeather
//
//  Created by WingleWong on 14-2-26.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMSplashAdController.h"
#import "DMRTSplashAdController.h"

#define UMENG_APPKEY @"5319800356240bc72c004290"
#define WECHAT_APPKEY @"wxfcf05fe5dc8c2b4b"

@class MSDynamicsDrawerViewController;

@interface LWAppDelegate : UIResponder <UIApplicationDelegate, DMSplashAdControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) DMSplashAdController *splashAd;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
