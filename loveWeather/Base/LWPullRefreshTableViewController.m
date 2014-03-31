//
//  LWPullRefreshTableViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-18.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWPullRefreshTableViewController.h"
#import "NSObject+NSJSONSerialization.h"
#import <GDataXML-HTML/GDataXMLNode.h>
#import <TSMessages/TSMessage.h>
#import <LBBlurredImage/UIImageView+LBBlurredImage.h>
#import "LWWeaterModel.h"
#import "LWWeatherConditionView.h"
#import "UIImage+Additions.h"

#import "LWAirTableViewCell.h"
#import "LWIndexTableViewCell.h"
#import "LWForecastTableViewCell.h"
#import "LWCitySearchController.h"
#import "LWDataManager.h"


#import <Google-AdMob-Ads-SDK/GADBannerView.h>
#import <Google-AdMob-Ads-SDK/GADRequest.h>
#import <UMengAnalytics/MobClick.h>
#import <MessageUI/MessageUI.h>

#define LWDT        @"lwdt"
#define LWINDEX     @"lwindex"
#define LWAIR       @"lwair"
#define LWCC        @"lwcc"
#define LWDW        @"lwdw"

@interface LWPullRefreshTableViewController () <GADBannerViewDelegate, LWCitySearchControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *weatherData;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) LWWeatherConditionView *headView;

@property(nonatomic, strong) GADBannerView *adBanner;

@end

@implementation LWPullRefreshTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect headerFrame = [UIScreen mainScreen].bounds;

    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    
    UIImage *background = [UIImage imageWithColor:LW_MAIN_COLOR];
    
    // 2
    self.backgroundImageView = [[UIImageView alloc] initWithImage:background];
    self.backgroundImageView.frame = CGRectMake(0, -64.f, headerFrame.size.width, headerFrame.size.height);
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    // 3
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.frame = CGRectMake(0, -64.f, headerFrame.size.width, headerFrame.size.height);
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
    [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
    [self.view addSubview:self.blurredImageView];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (_refreshHeaderView == nil) {
		
		LWRefreshTableHeaderView *view = [[LWRefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height) arrowImageName:@"weather-clear" textColor:[UIColor whiteColor]];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		
	}
    
    // 1
    headerFrame.size.height = headerFrame.size.height - 64.f;
    // 2
    self.headView = [[LWWeatherConditionView alloc] initWithFrame:headerFrame];
    self.headView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = self.headView;
    
    
    if (self.dataSource == nil) {
        self.dataSource = [NSMutableArray arrayWithCapacity:0];
    }
    
    if (self.weatherData == nil) {
        self.weatherData = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    
    CGPoint origin = CGPointMake(0.0,
                                headerFrame.size.height);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    self.adBanner = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    
    // Note: Edit SampleConstants.h to provide a definition for kSampleAdUnitID before compiling.
    self.adBanner.adUnitID = kSampleAdUnitID;
    self.adBanner.delegate = self;
    self.adBanner.rootViewController = self;
    [self.view addSubview:self.adBanner];
    [self.adBanner loadRequest:[self request]];
    
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    //--
    if ([[LWDataManager defaultManager] citysCount] == 0) {
        [self rightItemClicked:nil];
    }
    
    UIMenuItem *menuItem = [[UIMenuItem alloc]initWithTitle:@"短信发送" action:@selector(sendSMS:)];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuItems:[NSArray arrayWithObject:menuItem]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"天气页面"];
    CGPoint offset = CGPointMake(0, -65.0);
    self.tableView.contentOffset = offset;
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"天气页面"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    LOG(@"LWPullRefreshTableViewController dealloc...");
}

#pragma mark - Network actions

- (BOOL)requestWeatherDataByArea:(NSString *)area {
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
            NSString *mojiURL = [respDict objectForKey:@"result"];
            ASIHTTPRequest *mojiRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:mojiURL]];
            [mojiRequest setUserAgentString:@"Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko"];
            [mojiRequest setDelegate:self];
            [mojiRequest startAsynchronous];
        }else {
            return NO;
        }
        return YES;
    }else {
        return NO;
    }
}

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

#pragma mark - Action Methods 
- (void)sendSMS:(id)sender {
    NSLog(@"sendSMS");
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的设备不支持短信发送。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *smsText = [self.headView.tipsTextView.text substringFromIndex:6];
    
    NSString *message = [NSString stringWithFormat:@"%@", smsText];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}
- (void)rightItemClicked:(id)sender {
    LWCitySearchController *searchController = [[LWCitySearchController alloc] initWithNibName:@"LWCitySearchController" bundle:nil];
    searchController.delegate = self;
    UINavigationController *naviCv = [[UINavigationController alloc] initWithRootViewController:searchController];
    [self presentViewController:naviCv animated:YES completion:nil];
}

- (NSDictionary *)imageMap {
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        _imageMap = @{
                      @"0" : @"weather-clear",
                      @"1" : @"weather-few",
                      @"2" : @"weather-broken",
                      @"3" : @"weather-rain",
                      @"4" : @"weather-tstorm",
                      @"7" : @"weather-drizzle",
                      @"8" : @"weather-mrain",
                      @"9" : @"weather-shower",
                      @"10" : @"weather-hr",
                      @"13" : @"weather-snow",
                      @"18" : @"weather-mist",
                      };
    }
    return _imageMap;
}

- (NSString *)tipsMessage:(NSInteger)hour {
    NSString *message = nil;
    switch (hour) {
        case 0:
        case 1:
        case 2:
            message = @"夜深了，休息吧";
            break;
        case 3:
        case 4:
            message = @"注意身体，热杯牛奶吧";
            break;
        case 5:
        case 6:
        case 7:
        case 8:
            message = @"记得吃早餐哦";
            break;
        case 9:
        case 10:
            message = @"新的一天开始了";
            break;
        case 11:
        case 12:
            message = @"午饭时间，记得按时吃饭";
            break;
        case 13:
            message = @"眯一会吧";
            break;
        case 14:
        case 15:
        case 16:
        case 17:
            message = @"奋斗吧";
            break;
        case 18:
            message = @"晚饭时间，记得按时吃饭";
            break;
        case 19:
        case 20:
            message = @"有空就给父母打个电话吧";
            break;
        case 21:
        case 22:
        case 23:
            message = @"早点休息";
            break;
        default:
            break;
    }
    return message;
}

- (void)showTipsInHeadView {
    NSMutableString *tipsMessage = [[NSMutableString alloc] initWithCapacity:1];

    NSDate *nowDate = [NSDate date];
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    df_utc.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    NSArray *dateArray = [[df_utc stringFromDate:nowDate] componentsSeparatedByString:@" "];
    
    NSString *tmpMsg = [self tipsMessage:[[dateArray[1] componentsSeparatedByString:@":"][0] integerValue]];
    self.headView.comeonLabel.text = tmpMsg;
    
    [tipsMessage appendString:@"孝心提示：\n"];
    
    NSArray *dts = [self.weatherData objectForKey:LWDT];
    LWDt *dt = dts[0];
    [tipsMessage appendString:[NSString stringWithFormat:@"1.%@。\n",dt.newkn ? dt.newkn : dt.kn]];
    
    int i = 2;
    NSArray *idxs = [self.weatherData objectForKey:LWINDEX];
    for (LWIdxs *idx in idxs) {
        if (idx.type == 5 || idx.type == 11 || idx.type == 17) {
            [tipsMessage appendString:[NSString stringWithFormat:@"%d.%@\n", i, idx.recom]];
            i ++;
        }
    }
    
    NSArray *dws = [self.weatherData objectForKey:LWDW];
    for (LWDw *dw in dws) {
        [tipsMessage appendString:[NSString stringWithFormat:@"%d.%@，%@\n", i, dw.desc, dw.info]];
        i++;
    }
    
    self.headView.tipsTextView.text = tipsMessage;
    
}

- (void)reloadWeatherData {
    LWCc *cc = [self.weatherData objectForKey:LWCC];
    self.headView.temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",[cc.tmp floatValue]];
    self.headView.conditionsLabel.text = cc.wd;
    self.headView.hiloLabel.text = [NSString  stringWithFormat:@"%.0f° / %.0f°",[cc.ltmp floatValue], [cc.htmp floatValue]];
    self.headView.chieseDateLabel.text = [NSString stringWithFormat:@"%@\n%@", cc.gdt, cc.ldt];
    self.headView.humLabel.text = [NSString stringWithFormat:@"湿度 : %@ %%", cc.hum];
    self.headView.iconView.image = [UIImage imageNamed:[self imageMap][cc.wid]];
    
    [self showTipsInHeadView];
    
    BOOL isLoadAgain = [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoadAgain"];
    if (!isLoadAgain) {
        [TSMessage showNotificationWithTitle:@"使用提示"
                                    subtitle:@"长按“孝心提示”区域的文字可以将文字以短消息发送给父母。"
                                        type:TSMessageNotificationTypeMessage];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoadAgain"];
    }
    
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    CGFloat height = 0;
    switch (row) {
        case 0:
            height = 50.f;
            break;
        case 1:
            height = 120.f;
            break;
        case 2:
            height = 313.f;
            break;
        case 3:
            height = 220.f;
            break;
            
        default:
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *airCellIdentifier = @"airCell";
    static NSString *indexCellIdentifier = @"indexCell";
    static NSString *forecastCellIdentifier = @"forecastCell";
    static NSString *adCellIdentifier = @"adCell";
    
    NSInteger row = [indexPath row];
    
    if (row == 1) {
        LWAirTableViewCell *cell = (LWAirTableViewCell *)[tableView dequeueReusableCellWithIdentifier:airCellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LWAirTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        LWAir *air = [self.weatherData objectForKey:LWAIR];
        if (air == nil) {
            [cell.descLabel setTextColor:[UIColor whiteColor]];
            cell.indexLabel.text = @"N/A";
            cell.descLabel.text = @"无数据";
            cell.pm25Label.text = nil;
            cell.pm10Label.text = nil;
            cell.so2Label.text = nil;
            cell.pTimeLabel.text = nil;
            cell.o3Label.text = nil;
            return cell;
        }
        cell.indexLabel.text = air.lv;
        cell.pm25Label.text = [NSString stringWithFormat:@"PM2.5 : %@",[air.pmtwoaqi isEqualToString:@""] ?  @"无" : air.pmtwoaqi];
        cell.pm10Label.text = [NSString stringWithFormat:@"PM10 : %@",[air.pmtenaqi isEqualToString:@""] ?  @"无" : air.pmtenaqi];
        cell.so2Label.text = [NSString stringWithFormat:@"二氧化硫 : %@",[air.so2 isEqualToString:@""] ? @"无" :air.so2];
        cell.o3Label.text = [NSString stringWithFormat:@"臭氧 : %@",[air.o3 isEqualToString:@""] ? @"无" : air.o3];
        NSArray *info = [air.ptime componentsSeparatedByString:@" "];
        if ([info count] == 2) {
            NSString *strTime = [info[1] substringToIndex:5];
            cell.pTimeLabel.text = [NSString stringWithFormat:@"%@ 发布",strTime];
        }else {
            cell.pTimeLabel.text = nil;
        }
        
        if ([air.aqigrade isEqualToString:@"重度污染"] || [air.aqigrade isEqualToString:@"严重污染"]) {
            [cell.descLabel setTextColor:[UIColor colorWithRed:194.f/255 green:49.f/255 blue:49.f/255 alpha:1.0]];
        }else if ([air.aqigrade isEqualToString:@"优"] || [air.aqigrade isEqualToString:@"良"]) {
            [cell.descLabel setTextColor:[UIColor greenColor]];
        }else {
            [cell.descLabel setTextColor:[UIColor whiteColor]];
        }
        
        cell.descLabel.text = air.aqigrade;
        return cell;
    }else if (row == 2) {
        LWIndexTableViewCell *cell = (LWIndexTableViewCell *)[tableView dequeueReusableCellWithIdentifier:indexCellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LWIndexTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSArray *idxs = [self.weatherData objectForKey:LWINDEX];
        for (LWIdxs *index in idxs) {
            NSString *title = [NSString stringWithFormat:@"%@ :", index.nm];
            NSString *message = [NSString stringWithFormat:@"%@，%@", index.desc, index.recom];
            switch (index.type) {
                case 5:
                {
                    cell.line1TitleLabel.text = title;
                    cell.line1Label.text = message;
                    break;
                }
                case 11:
                {
                    cell.line2TitleLabel.text = title;
                    cell.line2Label.text = message;
                    break;
                }
                case 17:
                {
                    cell.line3TitleLabel.text = title;
                    cell.line3Label.text = message;
                    break;
                }
                case 19:
                {
                    cell.line4TitleLabel.text = title;
                    cell.line4Label.text = message;
                    break;
                }
                default:
                    break;
            }
        }
        return cell;
        
    }else if (row == 3) {
        LWForecastTableViewCell *cell = (LWForecastTableViewCell *)[tableView dequeueReusableCellWithIdentifier:forecastCellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LWForecastTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        NSArray *dts = [self.weatherData objectForKey:LWDT];
        for (LWDt *dt in dts) {
            switch (dt.dtid) {
                case 2:
                {
                    cell.line1ImageView.image = [UIImage imageNamed:[self imageMap][dt.hwid]];
                    cell.l11Label.text = @"明天";
                    cell.l12Label.text = dt.wdir;
                    cell.l13Label.text = [NSString stringWithFormat:@"%.0f° / %.0f°", [dt.ltmp floatValue], [dt.htmp floatValue]];
                    break;
                }
                case 3:
                {
                    cell.line2ImageView.image = [UIImage imageNamed:[self imageMap][dt.hwid]];
                    cell.l21Label.text = @"后天";
                    cell.l22Label.text = dt.wdir;
                    cell.l23Label.text = [NSString stringWithFormat:@"%.0f° / %.0f°", [dt.ltmp floatValue], [dt.htmp floatValue]];
                    break;
                }
                case 4:
                {
                    cell.line3ImageView.image = [UIImage imageNamed:[self imageMap][dt.hwid]];
                    cell.l31Label.text = [dt.date substringFromIndex:5];
                    cell.l32Label.text = dt.wdir;
                    cell.l33Label.text = [NSString stringWithFormat:@"%.0f° / %.0f°", [dt.ltmp floatValue], [dt.htmp floatValue]];
                    break;
                }
                case 5:
                {
                    cell.line4ImageView.image = [UIImage imageNamed:[self imageMap][dt.hwid]];
                    cell.l41Label.text = [dt.date substringFromIndex:5];
                    cell.l42Label.text = dt.wdir;
                    cell.l43Label.text = [NSString stringWithFormat:@"%.0f° / %.0f°", [dt.ltmp floatValue], [dt.htmp floatValue]];
                    break;
                }
                    
                default:
                    break;
            }
        }
        return cell;
        
        
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:adCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:adCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            
            [cell.textLabel setTextColor:[UIColor whiteColor]];
            [cell.detailTextLabel setTextColor:[UIColor whiteColor]];
        }
        cell.textLabel.text = @"赞助支持，我们将用于产品优化";
        cell.detailTextLabel.text = @"支付宝账号：xiaoxintech@163.com";
        
        return cell;
    }
}

#pragma mark - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    if (![self requestWeatherDataByArea:self.navigationItem.title]) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
        [TSMessage showNotificationInViewController:self
                                              title:NSLocalizedString(@"更新失败", nil)
                                           subtitle:NSLocalizedString(@"检查下网络是否有问题!", nil)
                                               type:TSMessageNotificationTypeError
                                           duration:2
                               canBeDismissedByUser:YES];
    }
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [self reloadWeatherData];
	
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	[self reloadTableViewDataSource];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
	
}

#pragma mark - ASIHttpRequest Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request {
    if (request.responseStatusCode != 200) {
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
        return;
    }
    [self.weatherData removeAllObjects];
    
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:request.responseData error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
//    LOG(@"%@",xmlEle);
    
    NSArray *partyMembers = [xmlEle elementsForName:@"cts"];
    NSArray *ct = [partyMembers[0] elementsForName:@"ct"];
    NSArray *pages = [ct[0] elementsForName:@"pages"];
    NSArray *page = [pages[0] elementsForName:@"page"];
    for (GDataXMLElement *element in page) {
        GDataXMLNode *node = [element attributeForName:@"id"];
        NSString *stringValue = [node stringValue];
        if ([stringValue isEqualToString:@"main"]) {
            // dts
            NSArray *dtss = [element elementsForName:@"dts"];
            NSArray *dts = [dtss[0] elementsForName:@"dt"];
            NSMutableArray *dtData = [NSMutableArray arrayWithCapacity:0];
            for (GDataXMLElement *dt in dts) {
                LWDt *dtModel = [[LWDt alloc] init];
                
                dtModel.dtid = [[[dt attributeForName:@"id"] stringValue] integerValue];
                dtModel.date = [[dt attributeForName:@"date"] stringValue];
                dtModel.kn = [[dt attributeForName:@"kn"] stringValue];
                dtModel.newkn = [[dt attributeForName:@"newkn"] stringValue];
                dtModel.wdir = [[dt attributeForName:@"wdir"] stringValue];
                dtModel.hwd = [[dt attributeForName:@"hwd"] stringValue];
                dtModel.lwd = [[dt attributeForName:@"lwd"] stringValue];
                dtModel.ltmp = [[dt attributeForName:@"ltmp"] stringValue];
                dtModel.htmp = [[dt attributeForName:@"htmp"] stringValue];
                dtModel.hwid = [[dt attributeForName:@"hwid"] stringValue];
                dtModel.lwid = [[dt attributeForName:@"lwid"] stringValue];
                
                [dtData addObject:dtModel];
            }
            [self.weatherData setObject:dtData forKey:LWDT];
            
            // dws
            NSArray *dwss = [element elementsForName:@"dws"];
            NSArray *dwTop = [dwss[0] elementsForName:@"dw"];
            if (dwTop) {
                NSMutableArray *dwData = [NSMutableArray arrayWithCapacity:0];
                for (GDataXMLElement *dw in dwTop) {
                    LWDw *dwModel = [[LWDw alloc] init];
                    
                    dwModel.wdid = [[[dw attributeForName:@"id"] stringValue] integerValue];
                    dwModel.pt = [[dw attributeForName:@"pt"] stringValue];
                    dwModel.et = [[dw attributeForName:@"et"] stringValue];
                    dwModel.desc = [[dw attributeForName:@"desc"] stringValue];
                    dwModel.info = [[dw attributeForName:@"info"] stringValue];
                    dwModel.icon = [[dw attributeForName:@"icon"] stringValue];
                    
                    [dwData addObject:dwModel];
                }
                [self.weatherData setObject:dwData forKey:LWDW];
            }
            
            // cc
            NSArray *ccs = [element elementsForName:@"cc"];
            GDataXMLElement *cc = ccs[0];
            
            LWCc *ccModel = [[LWCc alloc] init];
            ccModel.gdt = [[cc attributeForName:@"gdt"] stringValue];
            ccModel.ldt = [[cc attributeForName:@"ldt"] stringValue];
            ccModel.upt = [[cc attributeForName:@"upt"] stringValue];
            ccModel.tmp = [[cc attributeForName:@"tmp"] stringValue];
            ccModel.htmp = [[cc attributeForName:@"htmp"] stringValue];
            ccModel.ltmp = [[cc attributeForName:@"ltmp"] stringValue];
            ccModel.wd = [[cc attributeForName:@"wd"] stringValue];
            ccModel.wid = [[cc attributeForName:@"wid"] stringValue];
            ccModel.wl = [[cc attributeForName:@"wl"] stringValue];
            ccModel.wdir = [[cc attributeForName:@"wdir"] stringValue];
            ccModel.hum = [[cc attributeForName:@"hum"] stringValue];
            ccModel.sr = [[cc attributeForName:@"sr"] stringValue];
            ccModel.ss = [[cc attributeForName:@"ss"] stringValue];
            
            [self.weatherData setObject:ccModel forKey:LWCC];
            
        }else if ([stringValue isEqualToString:@"index"]) {
            // idx
            NSArray *idxsTop = [element elementsForName:@"idxs"];
            NSArray *idxs = [idxsTop[0] elementsForName:@"idx"];
            NSMutableArray *idxData = [NSMutableArray arrayWithCapacity:0];
            for (GDataXMLElement *idx in idxs) {
                LWIdxs *idxModel = [[LWIdxs alloc] init];
                
                idxModel.type = [[[idx attributeForName:@"type"] stringValue] integerValue];
                idxModel.nm = [[idx attributeForName:@"nm"] stringValue];
                idxModel.lv = [[idx attributeForName:@"lv"] stringValue];
                idxModel.desc = [[idx attributeForName:@"desc"] stringValue];
                idxModel.recom = [[idx attributeForName:@"recom"] stringValue];
                
                [idxData addObject:idxModel];
            }
            [self.weatherData setObject:idxData forKey:LWINDEX];
            
            // air
            NSArray *airTop = [element elementsForName:@"air"];
            if (airTop) {
                GDataXMLElement *air = airTop[0];
                
                LWAir *airModel = [[LWAir alloc] init];
                airModel.cityid = [[[air attributeForName:@"cityid"] stringValue] integerValue];
                airModel.cityName = [[air attributeForName:@"cityName"] stringValue];
                airModel.title = [[air attributeForName:@"title"] stringValue];
                airModel.cityaveragename = [[air attributeForName:@"cityaveragename"] stringValue];
                airModel.lv = [[air attributeForName:@"lv"] stringValue];
                airModel.pmtwoaqi = [[air attributeForName:@"pmtwoaqi"] stringValue];
                airModel.pmtenaqi = [[air attributeForName:@"pmtenaqi"] stringValue];
                airModel.so2 = [[air attributeForName:@"so2"] stringValue];
                airModel.co = [[air attributeForName:@"co"] stringValue];
                airModel.no2 = [[air attributeForName:@"no2"] stringValue];
                airModel.o3 = [[air attributeForName:@"o3"] stringValue];
                airModel.aqigrade = [[air attributeForName:@"aqigrade"] stringValue];
                airModel.desc = [[air attributeForName:@"desc"] stringValue];
                airModel.ptime = [[air attributeForName:@"ptime"] stringValue];
                
                [self.weatherData setObject:airModel forKey:LWAIR];
            }
        }
        
    }
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
    [TSMessage showNotificationInViewController:self
                                          title:NSLocalizedString(@"更新失败", nil)
                                       subtitle:NSLocalizedString(@"检查下网络是否有问题!", nil)
                                           type:TSMessageNotificationTypeError
                                       duration:2
                           canBeDismissedByUser:YES];
}

#pragma mark - LWCitySearchControllerDelegate Methods
- (void)searchCitySuccess:(NSString *)cityName {
    self.navigationItem.title = cityName;
    [[LWDataManager defaultManager] addCityByName:cityName];
}

#pragma mark - MFMessage
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GADBannerViewDelegate implementation

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    LOG(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
    LOG(@"Failed to receive ad with error: %@", [error localizedFailureReason]);
}

@end
