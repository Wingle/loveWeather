//
//  LWDataManager.h
//  loveWeather
//
//  Created by WingleWong on 14-3-25.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWDataManager : NSObject

+ (instancetype)defaultManager;


- (NSUInteger)citysCount;
- (NSArray *)citys;
- (void)addCityByName:(NSString *)name;
- (void)removeCityByName:(NSString *)name;
- (void)dataLocalization;



@end
