//
//  LWForecastTableViewCell.m
//  loveWeather
//
//  Created by WingleWong on 14-3-24.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWForecastTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWForecastTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    _titleLabel.layer.masksToBounds = YES;
    _titleLabel.layer.borderWidth = 1.f;
    _titleLabel.layer.borderColor = [[UIColor yellowColor] CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
