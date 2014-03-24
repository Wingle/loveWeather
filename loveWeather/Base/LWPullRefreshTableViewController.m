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
#import <ReactiveCocoa/ReactiveCocoa/ReactiveCocoa.h>
#import "LWWeaterModel.h"
#import "LWWeatherConditionView.h"
#import "UIImage+Additions.h"

#import "LWAirTableViewCell.h"
#import "LWIndexTableViewCell.h"
#import "LWForecastTableViewCell.h"

#define LWDT        @"lwdt"
#define LWINDEX     @"lwindex"
#define LWAIR       @"lwair"
#define LWCC        @"lwcc"
#define LWDW        @"lwdw"

@interface LWPullRefreshTableViewController ()

@property (nonatomic, strong) NSMutableDictionary *weatherData;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) LWWeatherConditionView *headView;

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

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationController.navigationBar.translucent = YES;
    self.view.backgroundColor = [UIColor clearColor];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    self.tableView.pagingEnabled = YES;
    self.tableView.allowsSelection = NO;
    
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
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
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
    
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    CGPoint offset = CGPointMake(0, -65.0);
    self.tableView.contentOffset = offset;
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.tableView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Network actions

- (NSDictionary *)imageMap {
    // 1
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2
        _imageMap = @{
                      @"0" : @"weather-clear",
                      @"1" : @"weather-few",
                      @"2" : @"weather-broken",
                      @"?" : @"weather-shower",
                      @"7" : @"weather-rain",
                      @"4" : @"weather-tstorm",
                      @"13" : @"weather-snow",
                      @"?" : @"weather-mist",
                      };
    }
    return _imageMap;
}

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

- (void)reloadWeatherData {
    LWCc *cc = [self.weatherData objectForKey:LWCC];
    self.headView.temperatureLabel.text = [NSString stringWithFormat:@"%.0f°",[cc.tmp floatValue]];
    self.headView.conditionsLabel.text = cc.wd;
    self.headView.hiloLabel.text = [NSString  stringWithFormat:@"%.0f° / %.0f°",[cc.ltmp floatValue], [cc.htmp floatValue]];
    self.headView.chieseDateLabel.text = [NSString stringWithFormat:@"%@\n%@", cc.gdt, cc.ldt];
    [self.headView.chieseDateLabel sizeToFit];
    self.headView.humLabel.text = [NSString stringWithFormat:@"湿度 : %@ %%", cc.hum];
    self.headView.iconView.image = [UIImage imageNamed:[self imageMap][cc.wid]];
    
    NSArray *dts = [self.weatherData objectForKey:LWDT];
    LWDt *dt = dts[0];
    NSString *tipsMessage = [NSString stringWithFormat:@"孝心提示:\n%@",dt.newkn ? dt.newkn : dt.kn];
    self.headView.tipsTextView.text = tipsMessage;
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return [self.dataSource count];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray *sectionData = self.dataSource[section];
//    return [sectionData count];
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    CGFloat height = 0;
    switch (row) {
        case 0:
            height = 120.f;
            break;
        case 1:
            height = 313.f;
            break;
        case 2:
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
    
    NSInteger row = [indexPath row];
    
    if (row == 0) {
        LWAirTableViewCell *cell = (LWAirTableViewCell *)[tableView dequeueReusableCellWithIdentifier:airCellIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"LWAirTableViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        LWAir *air = [self.weatherData objectForKey:LWAIR];
        cell.indexLabel.text = air.lv;
        cell.pm25Label.text = [NSString stringWithFormat:@"PM2.5 : %@",air.pmtwoaqi];
        cell.pm10Label.text = [NSString stringWithFormat:@"PM10 : %@",air.pmtenaqi];
        cell.so2Label.text = [NSString stringWithFormat:@"二氧化硫 : %@",air.so2];
        cell.o3Label.text = [NSString stringWithFormat:@"臭氧 : %@",air.o3];
        NSArray *info = [air.ptime componentsSeparatedByString:@" "];
        if ([info count] == 2) {
            NSString *strTime = [info[1] substringToIndex:5];
            cell.pTimeLabel.text = [NSString stringWithFormat:@"%@ 发布",strTime];
        }else {
            cell.pTimeLabel.text = nil;
        }
        
        if ([air.aqigrade isEqualToString:@"重度污染"]) {
            [cell.descLabel setTextColor:[UIColor colorWithRed:194.f/255 green:49.f/255 blue:49.f/255 alpha:1.0]];
        }else {
            [cell.descLabel setTextColor:[UIColor whiteColor]];
        }
        
        cell.descLabel.text = air.aqigrade;
        return cell;
    }else if (row == 1) {
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
                    [cell.line1Label sizeToFit];
                    break;
                }
                case 11:
                {
                    cell.line2TitleLabel.text = title;
                    cell.line2Label.text = message;
                    [cell.line2Label sizeToFit];
                    break;
                }
                case 17:
                {
                    cell.line3TitleLabel.text = title;
                    cell.line3Label.text = message;
                    [cell.line3Label sizeToFit];
                    break;
                }
                case 19:
                {
                    cell.line4TitleLabel.text = title;
                    cell.line4Label.text = message;
                    [cell.line4Label sizeToFit];
                    break;
                }
                default:
                    break;
            }
        }
        return cell;
        
    }else if (row == 2) {
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
        return nil;
    }
    

}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//	
//	return [NSString stringWithFormat:@"Section %ld", (long)section];
//	
//}

#pragma mark - Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    [self requestWeatherDataByArea:@"北京"];
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
    NSLog(@"%@",xmlEle);
    
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
    
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
    [TSMessage showNotificationWithTitle:NSLocalizedString(@"更新成功", nil)
                                subtitle:NSLocalizedString(@"孝心天气数据已经更新到最新的数据了!", nil)
                                    type:TSMessageNotificationTypeSuccess];
    
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0];
//    [TSMessage sh]
}

@end
