//
//  LWCitySearchController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-25.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWCitySearchController.h"
#import "DMAdView.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>
#import "NSObject+NSJSONSerialization.h"
#import "LWDataManager.h"
#import <UMengAnalytics/MobClick.h>

@interface LWCitySearchController () <DMAdViewDelegate, ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) DMAdView *adBanner;

@property (nonatomic, strong) UIBarButtonItem *leftItem;

@end

@implementation LWCitySearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray arrayWithCapacity:0];
        _leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(leftItemClicked:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[UINavigationBar appearance] setBarTintColor:LW_MAIN_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor whiteColor], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"Helvetica Neue" size:21.0], NSFontAttributeName, nil]];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = @"添加";
    
    // --
    self.navigationItem.leftBarButtonItem = self.leftItem;
    if ([[LWDataManager defaultManager] citysCount] == 0) {
        self.leftItem.enabled = NO;
        [self.dataSource addObject:@"欢迎使用孝心天气，来添加父母所在的地区吧"];
    }
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    
    // 创建广告视图，此处使用的是测试ID，请登陆多盟官网（www.domob.cn）获取新的ID
    self.adBanner = [[DMAdView alloc] initWithPublisherId:kDomobPublisherID
                                              placementId:@"16TLuUqoAphr2NUkHQSgRM1i"
                                              autorefresh:YES];
    // 设置广告视图的位置
    self.adBanner.frame = CGRectMake(0, bounds.size.height - FLEXIBLE_SIZE.height,
                                     FLEXIBLE_SIZE.width,
                                     FLEXIBLE_SIZE.height);
    
    self.adBanner.delegate = self; // 设置 Delegate
    self.adBanner.rootViewController = self; // 设置 RootViewController
    [self.view addSubview:self.adBanner];
    [self.adBanner loadAd]; // 开始加载广告

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"地区添加页"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"地区添加页"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - action

- (BOOL)requestWeatherDataByArea:(NSString *)area {
    [self.dataSource removeAllObjects];
    NSString *strURL = [[NSString stringWithFormat:@"http://weather.51juzhai.com/data/getHttpUrl?cityName=%@",area] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    LOG(@"request url = %@",strURL);
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strURL]];
    [request setUserAgentString:@"Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (!error && request.responseStatusCode == 200) {
        LOG(@"%@",request.responseString);
        NSDictionary *respDict = [request.responseString JSONValue];
        BOOL result = [[respDict objectForKey:@"success"] boolValue];
        if (result) {
            [self.dataSource addObject:area];
            [self.dataSource addObject:@"提示：点击列表中的名称来添加"];
        }else {
            [self.dataSource addObject:@"提示：试试该地区所在城市的名称？"];
            return NO;
        }
        return YES;
    }else {
        [self.dataSource addObject:@"提示：试试该地区所在城市的名称？"];
        return NO;
    }
}

- (void)leftItemClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView DataSourc Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    cell.textLabel.text = self.dataSource[[indexPath row]];
    return cell;
}

#pragma mark - UITableView Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource count] == 1) {
        return nil;
    }
    if ([indexPath row] == 0) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchCitySuccess:)]) {
        [self.delegate searchCitySuccess:self.dataSource[[indexPath row]]];
        //UMeng.
        [MobClick event:@"areaGot" label:self.dataSource[[indexPath row]]];
        
        [self leftItemClicked:nil];
    }
}

#pragma mark - search delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    LOG(@"searchBarSearchButtonClicked");
    NSString *searchText = searchBar.text;
    if (searchText == nil) {
        return;
    }
    [searchBar resignFirstResponder];
    
    NSRange range = [searchText rangeOfString:@"市"];
    if (range.location == NSNotFound) {
        range = [searchText rangeOfString:@"区"];
        if (range.location == NSNotFound) {
            range = [searchText rangeOfString:@"县"];
            if (range.location == NSNotFound) {
                
            }else {
                 searchText = [searchText substringToIndex:range.location];
            }
        }else {
             searchText = [searchText substringToIndex:range.location];
        }
    }else {
        searchText = [searchText substringToIndex:range.location];
    }
    LOG(@"%@",searchText);
    
    //UMeng.
    [MobClick event:@"searchText" label:searchText];
    
    __weak typeof(self) weakself = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.removeFromSuperViewOnHide = YES;
    [self.view addSubview:hud];
    [hud showAnimated:YES whileExecutingBlock:^(void){
        [weakself requestWeatherDataByArea:searchText];
    }onQueue:queue completionBlock:^(void){
        [weakself.tableView reloadData];
    }];
}




@end
