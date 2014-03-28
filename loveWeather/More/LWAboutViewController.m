//
//  LWAboutViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-27.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWAboutViewController.h"
#import <MessageUI/MessageUI.h>
#import <UMengAnalytics/MobClick.h>

@interface LWAboutViewController () <MFMailComposeViewControllerDelegate>

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"关于页面"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"关于页面"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Methods

- (IBAction)sponsorButtonClicked:(id)sender {
    NSString *sponsorLink = @"https://me.alipay.com/xiaoxintech";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sponsorLink]];
    
    [MobClick event:@"sponsor"];
}

- (IBAction)emailButtonClicked:(id)sender {
    NSString *emailTitle = @"产品反馈";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"xiaoxintech@163.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
    [MobClick event:@"emailFB"];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            LOG(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            LOG(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            LOG(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            LOG(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}
@end
