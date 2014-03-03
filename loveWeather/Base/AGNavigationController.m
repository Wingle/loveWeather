//
//  AGNavigationController.m
//  AnyGo
//
//  Created by WingleWong on 14-2-11.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "AGNavigationController.h"

@interface AGNavigationController ()

@end

@implementation AGNavigationController

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
	// Do any additional setup after loading the view.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
