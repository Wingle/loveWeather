//
//  LWPullRefreshTableViewController.h
//  loveWeather
//
//  Created by WingleWong on 14-3-18.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWTableViewController.h"
#import <EGOTableViewPullRefresh/EGORefreshTableHeaderView.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>


@interface LWPullRefreshTableViewController : LWTableViewController <EGORefreshTableHeaderDelegate, ASIHTTPRequestDelegate> {
    EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
}

- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;



@end
