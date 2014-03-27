//
//  LWAboutViewController.m
//  loveWeather
//
//  Created by WingleWong on 14-3-27.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWAboutViewController.h"
#import <MessageUI/MessageUI.h>

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
    NSString *emailTitle = @"[孝心天气]产品反馈";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"xiaoxintech@163.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
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
