//
//  LWTaoBaoCell.m
//  loveWeather
//
//  Created by Wingle Wong on 10/28/14.
//  Copyright (c) 2014 WingleWong. All rights reserved.
//

#import "LWTaoBaoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWTaoBaoCell

- (void)awakeFromNib {
    // Initialization code
    self.avaterImageView.clipsToBounds = YES;
    self.avaterImageView.layer.masksToBounds = YES;
    self.avaterImageView.layer.cornerRadius = CGRectGetWidth(self.avaterImageView.bounds)/2.f;
    
    _titleLabel.layer.masksToBounds = YES;
    _titleLabel.layer.borderWidth = 1.f;
    _titleLabel.layer.borderColor = [[UIColor colorWithRed:115.f/255 green:203.f/255 blue:195.f/255 alpha:1.f] CGColor];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
