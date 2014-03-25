//
//  LWIndexTableViewCell.h
//  loveWeather
//
//  Created by WingleWong on 14-3-24.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWIndexTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *line1Label;
@property (weak, nonatomic) IBOutlet UILabel *line2Label;
@property (weak, nonatomic) IBOutlet UILabel *line3Label;
@property (weak, nonatomic) IBOutlet UILabel *line4Label;

@property (weak, nonatomic) IBOutlet UILabel *line1TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *line2TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *line3TitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *line4TitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
