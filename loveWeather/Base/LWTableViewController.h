//
//  LWTableViewController.h
//  loveWeather
//
//  Created by WingleWong on 14-3-27.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWTableViewController : UITableViewController
@property (nonatomic, strong) UIBarButtonItem *rightItem;
@property (nonatomic, strong) UIBarButtonItem *shareItem;

- (void)rightItemClicked:(id)sender;
- (void)shareItemButtonClicked:(id)sender;

@end
