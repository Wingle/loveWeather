//
//  LWMenuViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-3.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWMenuViewController.h"
#import "MSDynamicsDrawerStyler.h"
#import "MSDynamicsDrawerViewController.h"
#import "MSMenuCell.h"
#import "MSMenuTableViewHeader.h"
#import "LWDataManager.h"

#import "LWPullRefreshTableViewController.h"
#import "LWCitiesManagerViewController.h"
#import "LWAboutViewController.h"


NSString * const MSMenuCellReuseIdentifier = @"Drawer Cell";
NSString * const MSDrawerHeaderReuseIdentifier = @"Drawer Header";

typedef NS_ENUM(NSUInteger, MSMenuViewControllerTableViewSectionType) {
    MSMenuViewControllerTableViewSectionTypeOptions,
    MSMenuViewControllerTableViewSectionTypeAbout,
    MSMenuViewControllerTableViewSectionTypeCount
};

@interface LWMenuViewController ()

@property (nonatomic, strong) NSDictionary *paneViewControllerTitles;
@property (nonatomic, strong) NSDictionary *paneViewControllerClasses;
@property (nonatomic, strong) NSDictionary *sectionTitles;
@property (nonatomic, strong) NSArray *tableViewSectionBreaks;


@end

@implementation LWMenuViewController

#pragma mark - NSObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

#pragma mark - UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self initialize];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[MSMenuCell class] forCellReuseIdentifier:MSMenuCellReuseIdentifier];
    [self.tableView registerClass:[MSMenuTableViewHeader class] forHeaderFooterViewReuseIdentifier:MSDrawerHeaderReuseIdentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1.0 alpha:0.25];
    
    CGRect bounds = self.view.bounds;
    CGFloat inset = 10.f;
    CGFloat iconHeight = 30.f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 80.f)];
    view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(bounds.size.width/2 - iconHeight/2, 10.f, iconHeight, iconHeight)];
    [imageView setImage:[UIImage imageNamed:@"weather-clear"]];
    [view addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(inset, 10 + iconHeight + 10.f, bounds.size.width - 2*inset, 21.f)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    titleLabel.text = @"孝心天气";
    [view addSubview:titleLabel];
    
    self.tableView.tableFooterView = view;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MSMenuViewController

- (void)initialize
{
    self.paneViewControllerType = NSUIntegerMax;

    self.paneViewControllerTitles = @{
                                      @(MSPaneViewControllerTypeManager) : @"地区管理",
                                      @(MSPaneViewControllerTypeAbout) : @"关于孝心"
                                      };
    
    self.paneViewControllerClasses = @{
                                       @(MSPaneViewControllerTypeWeather) : [LWPullRefreshTableViewController class],
                                       @(MSPaneViewControllerTypeManager) : [LWCitiesManagerViewController class],
                                       @(MSPaneViewControllerTypeAbout)   : [LWAboutViewController class],
                                       };
    
    self.sectionTitles = @{
                           @(MSMenuViewControllerTableViewSectionTypeOptions) : @"地区",
                           @(MSMenuViewControllerTableViewSectionTypeAbout) : @"选项",
                           };
    
    self.tableViewSectionBreaks = @[
                                    @(MSPaneViewControllerTypeManager),
                                    @(MSPaneViewControllerTypeAbout)
                                    ];
    
}

- (MSPaneViewControllerType)paneViewControllerTypeForIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType;
    if (indexPath.section == 0) {
        paneViewControllerType = MSPaneViewControllerTypeWeather;
    } else {
        paneViewControllerType = [self.tableViewSectionBreaks[[indexPath row]] integerValue];
    }
    return paneViewControllerType;
}

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType cityAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL animateTransition = self.dynamicsDrawerViewController.paneViewController != nil;
    
    Class paneViewControllerClass = self.paneViewControllerClasses[@(paneViewControllerType)];
    UIViewController *paneViewController = (UIViewController *)[paneViewControllerClass new];
    
    NSString *cityName = nil;
    if (indexPath) {
        if ([indexPath section] == 0) {
            cityName = [[LWDataManager defaultManager] citys][[indexPath row]];
            paneViewController.navigationItem.title = cityName;
        }else {
            paneViewController.navigationItem.title = self.paneViewControllerTitles[@(paneViewControllerType)];
        }
    }else {
        paneViewController.navigationItem.title = [[[LWDataManager defaultManager] citys] lastObject];
        
    }
    
    UINavigationController *paneNavigationViewController = [[UINavigationController alloc] initWithRootViewController:paneViewController];
    [self.dynamicsDrawerViewController setPaneViewController:paneNavigationViewController animated:animateTransition completion:nil];
    
    self.paneViewControllerType = paneViewControllerType;
    if (cityName) {
        [[LWDataManager defaultManager] addCityByName:cityName];
        [[LWDataManager defaultManager] dataLocalization];
    }
}

- (void)dynamicsDrawerRevealLeftBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionLeft animated:YES allowUserInterruption:YES completion:nil];
}

- (void)dynamicsDrawerRevealRightBarButtonItemTapped:(id)sender
{
    [self.dynamicsDrawerViewController setPaneState:MSDynamicsDrawerPaneStateOpen inDirection:MSDynamicsDrawerDirectionRight animated:YES allowUserInterruption:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [[[LWDataManager defaultManager] citys] count];
    } else {
        return [self.tableViewSectionBreaks count];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:MSDrawerHeaderReuseIdentifier];
    headerView.textLabel.text = self.sectionTitles[@(section)];
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new]; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN; // Hacky way to prevent extra dividers after the end of the table from showing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MSMenuCellReuseIdentifier forIndexPath:indexPath];
    if ([indexPath section] == 0) {
        cell.textLabel.text = [[LWDataManager defaultManager] citys][[indexPath row]];
    }else {
        cell.textLabel.text = self.paneViewControllerTitles[@([self paneViewControllerTypeForIndexPath:indexPath])];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MSPaneViewControllerType paneViewControllerType = [self paneViewControllerTypeForIndexPath:indexPath];
    [self transitionToViewController:paneViewControllerType cityAtIndexPath:indexPath];
    
    // Prevent visual display bug with cell dividers
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.tableView reloadData];
    });
}

#pragma mark - MSDynamicsDrawerViewControllerDelegate

- (void)dynamicsDrawerViewController:(MSDynamicsDrawerViewController *)dynamicsDrawerViewController didUpdateToPaneState:(MSDynamicsDrawerPaneState)state
{
    // Ensure that the pane's table view can scroll to top correctly
    self.tableView.scrollsToTop = (state == MSDynamicsDrawerPaneStateOpen);
}

@end
