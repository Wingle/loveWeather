//
//  LWAboutViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-27.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWAboutViewController.h"

@interface LWAboutViewController ()

@end

@implementation LWAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sponsorButtonClicked:(id)sender {
    NSString *sponsorLink = @"https://me.alipay.com/xiaoxintech";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sponsorLink]];
}

- (IBAction)emailButtonClicked:(id)sender {
}
@end
