//
//  LWCitiesManagerViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-26.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWCitiesManagerViewController.h"
#import "LWDataManager.h"
#import "LWCitySearchController.h"
#import <UMengAnalytics/MobClick.h>
#import <Google-AdMob-Ads-SDK/GADBannerView.h>
#import <Google-AdMob-Ads-SDK/GADRequest.h>

NSString * const cellIdentifier = @"reuseIdentifier";

@interface LWCitiesManagerViewController () <LWCitySearchControllerDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) GADBannerView *adBanner;

@end

@implementation LWCitiesManagerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 21.f)];
    UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, 21.f)];
    tipsLabel.font = [UIFont systemFontOfSize:14];
    tipsLabel.textColor = [UIColor colorWithRed:160.f/255 green:165.f/255 blue:178.f/255 alpha:1];
    tipsLabel.text = @"提示：地区可以滑动删除";
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    [headView addSubview:tipsLabel];
    self.tableView.tableHeaderView = headView;
    
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.tableView.tableHeaderView = nil;
    });
    
    CGPoint origin = CGPointMake(0.0,
                                 bounds.size.height - 50.f);
    // Use predefined GADAdSize constants to define the GADBannerView.
    self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    
    // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
    self.adBanner.adUnitID = kSampleAdUnitID;
    self.adBanner.delegate = self;
    self.adBanner.rootViewController = self;
    [[UIApplication sharedApplication].windows[0] addSubview:self.adBanner];
    [self.adBanner loadRequest:[self request]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"地区管理页"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"地区管理页"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.adBanner removeFromSuperview];
    self.adBanner = nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[LWDataManager defaultManager] citysCount];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [[LWDataManager defaultManager] citys][[indexPath row]];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[LWDataManager defaultManager] removeCityByName:[[LWDataManager defaultManager] citys][row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.f;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

#pragma mark - Action Methods
- (void)rightItemClicked:(id)sender {
    LWCitySearchController *searchController = [[LWCitySearchController alloc] initWithNibName:@"LWCitySearchController" bundle:nil];
    searchController.delegate = self;
    UINavigationController *naviCv = [[UINavigationController alloc] initWithRootViewController:searchController];
    [self presentViewController:naviCv animated:YES completion:nil];
}

#pragma mark - action
- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad. Put in an identifier for the simulator as well as any devices
    // you want to receive test ads.
    request.testDevices = @[
                            // TODO: Add your device/simulator test identifiers here. Your device identifier is printed to
                            // the console when the app is launched.
                            GAD_SIMULATOR_ID,
                            @"672e13ff37a8c1e99a51375df44e9f4c9f610d7f",
                            @"5ea83bfbbab6d8e72c936fa4888757666a28a4c0"
                            ];
    return request;
}

#pragma mark - LWCitySearchControllerDelegate Methods
- (void)searchCitySuccess:(NSString *)cityName {
    [[LWDataManager defaultManager] addCityByName:cityName];
    [self.tableView reloadData];
}

@end
