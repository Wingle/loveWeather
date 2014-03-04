//
//  LWDailyForecast.m
//  loveWeather
//
//  Created by WingleWong on 14-3-4.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWDailyForecast.h"

@implementation LWDailyForecast

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    // 1
    NSMutableDictionary *paths = [[super JSONKeyPathsByPropertyKey] mutableCopy];
    // 2
    paths[@"tempHigh"] = @"temp.max";
    paths[@"tempLow"] = @"temp.min";
    // 3
    return paths;
}

@end
