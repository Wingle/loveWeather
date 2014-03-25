//
//  LWMenuViewController.h
//  loveWeather
//
//  Created by WingleWong on 14-3-3.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSDynamicsDrawerViewController;

typedef NS_ENUM(NSUInteger, MSPaneViewControllerType) {
    MSPaneViewControllerTypeWeather,
    MSPaneViewControllerTypeSetting,
    MSPaneViewControllerTypeVersion
};

@interface LWMenuViewController : UITableViewController

@property (nonatomic, assign) MSPaneViewControllerType paneViewControllerType;
@property (nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType cityAtIndexPath:(NSIndexPath *)indexPath;

@end
