//
//  LWWeatherConditionView.m
//  loveWeather
//
//  Created by WingleWong on 14-3-19.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWWeatherConditionView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWWeatherConditionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // 2
        CGFloat inset = 15;
        CGFloat tipsInset = 40.f;
        // 3
        CGFloat temperatureHeight = 110.f;
        CGFloat temperatureWidth = 200.f;
        CGFloat humHeight = 20;
        CGFloat hiloHeight = 40;
        CGFloat iconHeight = 30;
        CGFloat tipsSize = frame.size.width - 2*tipsInset;
        CGFloat labelWidth = frame.size.width/2 - inset;
        // 4
        
        CGRect tipsFrame = CGRectMake(tipsInset,
                                      20,
                                      tipsSize,
                                      200.f);
        
        CGRect hiloFrame = CGRectMake(inset,
                                      frame.size.height - hiloHeight,
                                      labelWidth,
                                      hiloHeight);
        
        CGRect chieseDateFrame = CGRectMake(frame.size.width/2 + 10,
                                            frame.size.height - hiloHeight,
                                            labelWidth,
                                            hiloHeight);
        
        CGRect temperatureFrame = CGRectMake(inset,
                                             frame.size.height - (temperatureHeight + hiloHeight),
                                             temperatureWidth,
                                             temperatureHeight);
        
        CGRect comeonFrame = CGRectMake(temperatureWidth,
                                        frame.size.height - (temperatureHeight + hiloHeight) + 10.f,
                                        frame.size.width - temperatureWidth,
                                        40.f);
        
        CGRect humFrame = CGRectMake(frame.size.width/2 + 10,
                                     frame.size.height - (temperatureHeight + hiloHeight) + 80,
                                     labelWidth,
                                     humHeight);
        
        CGRect iconFrame = CGRectMake(inset,
                                      temperatureFrame.origin.y - iconHeight,
                                      iconHeight,
                                      iconHeight);
        
        CGRect conditionsFrame = iconFrame;
        conditionsFrame.size.width = frame.size.width - (((2 * inset) + iconHeight) + 10);
        conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
        
        // come on
        _comeonLabel = [[UILabel alloc] initWithFrame:comeonFrame];
        _comeonLabel.backgroundColor = [UIColor clearColor];
        _comeonLabel.textColor = [UIColor whiteColor];
        _comeonLabel.textAlignment = NSTextAlignmentLeft;
        _comeonLabel.numberOfLines = 2;
        _comeonLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [self addSubview:_comeonLabel];
        
        // tips
        _tipsTextView = [[LWTextView alloc] initWithFrame:tipsFrame];
        _tipsTextView.backgroundColor = [UIColor clearColor];
        _tipsTextView.textColor = [UIColor whiteColor];
        _tipsTextView.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        _tipsTextView.editable = NO;
        
        [self addSubview:_tipsTextView];
        
        // bottom left
        _temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
        _temperatureLabel.backgroundColor = [UIColor clearColor];
        _temperatureLabel.textColor = [UIColor whiteColor];
        _temperatureLabel.text = @"0°";
        _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
        [self addSubview:_temperatureLabel];
        
        _humLabel = [[UILabel alloc] initWithFrame:humFrame];
        _humLabel.backgroundColor = [UIColor clearColor];
        _humLabel.textColor = [UIColor whiteColor];
        _humLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        [self addSubview:_humLabel];
        
        // bottom left
        _hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
        _hiloLabel.backgroundColor = [UIColor clearColor];
        _hiloLabel.textColor = [UIColor whiteColor];
        _hiloLabel.text = @"0° / 0°";
        _hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        [self addSubview:_hiloLabel];
        
        _conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
        _conditionsLabel.backgroundColor = [UIColor clearColor];
        _conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        _conditionsLabel.textColor = [UIColor whiteColor];
        [self addSubview:_conditionsLabel];
        
        _chieseDateLabel = [[UILabel alloc] initWithFrame:chieseDateFrame];
        _chieseDateLabel.backgroundColor = [UIColor clearColor];
        _chieseDateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        _chieseDateLabel.textColor = [UIColor whiteColor];
        _chieseDateLabel.numberOfLines = 2;
        [self addSubview:_chieseDateLabel];
        
        // bottom left
        _iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconView];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
