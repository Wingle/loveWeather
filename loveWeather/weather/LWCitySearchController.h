//
//  LWCitySearchController.h
//  loveWeather
//
//  Created by WingleWong on 14-3-25.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LWCitySearchControllerDelegate <NSObject>

- (void)searchCitySuccess:(NSString *)cityName;

@end

@interface LWCitySearchController : UIViewController
@property (weak, nonatomic) id<LWCitySearchControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISearchBar *citySearchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
