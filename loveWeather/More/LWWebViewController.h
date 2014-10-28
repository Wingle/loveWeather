//
//  LWWebViewController.h
//  loveWeather
//
//  Created by Wingle Wong on 10/22/14.
//  Copyright (c) 2014 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWebViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, copy) NSString *strURL;

@end
