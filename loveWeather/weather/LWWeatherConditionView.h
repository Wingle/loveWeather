//
//  LWWeatherConditionView.h
//  loveWeather
//
//  Created by WingleWong on 14-3-19.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWeatherConditionView : UIView

@property (nonatomic, strong) UILabel *temperatureLabel;
@property (nonatomic, strong) UILabel *humLabel;
@property (nonatomic, strong) UILabel *hiloLabel;
@property (nonatomic, strong) UILabel *conditionsLabel;
@property (nonatomic, strong) UILabel *chieseDateLabel;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UITextView *tipsTextView;

@end
