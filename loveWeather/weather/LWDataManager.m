//
//  LWDataManager.m
//  loveWeather
//
//  Created by WingleWong on 14-3-25.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWDataManager.h"

@interface LWDataManager () {
    NSMutableArray *_citySouce;
}

@end

@implementation LWDataManager

- (id)init {
    self = [super init];
    if (self) {
        _citySouce = [NSMutableArray arrayWithCapacity:0];
        NSArray *citys = [[NSUserDefaults standardUserDefaults] objectForKey:LW_CITY_LIST];
        if (citys) {
            [_citySouce addObjectsFromArray:citys];
        }
    }
    return self;
}

+ (instancetype)defaultManager {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - APIs

- (NSUInteger)citysCount {
    return [_citySouce count];
}

- (NSArray *)citys {
    return _citySouce;
}

- (void)addCityByName:(NSString *)name {
    if (name == nil) {
        return;
    }
    [_citySouce addObject:name];
}

- (void)removeCityByName:(NSString *)name {
    if (name == nil) {
        return;
    }
    [_citySouce removeObject:name];
}

- (void)dataLocalization {
    [[NSUserDefaults standardUserDefaults] setObject:_citySouce forKey:LW_CITY_LIST];
    [[NSUserDefaults standardUserDefaults] synchronize];
}





@end
