//
//  LWForecastTableViewCell.h
//  loveWeather
//
//  Created by WingleWong on 14-3-24.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWForecastTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *line1ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *line2ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *line3ImageView;
@property (weak, nonatomic) IBOutlet UIImageView *line4ImageView;

@property (weak, nonatomic) IBOutlet UILabel *l11Label;
@property (weak, nonatomic) IBOutlet UILabel *l21Label;
@property (weak, nonatomic) IBOutlet UILabel *l31Label;
@property (weak, nonatomic) IBOutlet UILabel *l41Label;

@property (weak, nonatomic) IBOutlet UILabel *l12Label;
@property (weak, nonatomic) IBOutlet UILabel *l22Label;
@property (weak, nonatomic) IBOutlet UILabel *l32Label;
@property (weak, nonatomic) IBOutlet UILabel *l42Label;

@property (weak, nonatomic) IBOutlet UILabel *l13Label;
@property (weak, nonatomic) IBOutlet UILabel *l23Label;
@property (weak, nonatomic) IBOutlet UILabel *l33Label;
@property (weak, nonatomic) IBOutlet UILabel *l43Label;


@end
