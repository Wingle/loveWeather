//
//  LWWeaterModel.h
//  loveWeather
//
//  Created by WingleWong on 14-3-18.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LWDt : NSObject

@property (nonatomic, assign) NSInteger dtid;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *kn;
@property (nonatomic, copy) NSString *newkn;
@property (nonatomic, copy) NSString *wdir;
@property (nonatomic, copy) NSString *hwd;
@property (nonatomic, copy) NSString *lwd;
@property (nonatomic, copy) NSString *ltmp;
@property (nonatomic, copy) NSString *htmp;

@end

@interface LWCc : NSObject

@property (nonatomic, copy) NSString *gdt;
@property (nonatomic, copy) NSString *ldt;
@property (nonatomic, copy) NSString *upt;
@property (nonatomic, copy) NSString *tmp;
@property (nonatomic, copy) NSString *htmp;
@property (nonatomic, copy) NSString *ltmp;
@property (nonatomic, copy) NSString *wd;
@property (nonatomic, copy) NSString *wl;
@property (nonatomic, copy) NSString *wdir;
@property (nonatomic, copy) NSString *sr;
@property (nonatomic, copy) NSString *ss;

@end

@interface LWIdxs : NSObject

@property (nonatomic, assign) NSInteger type;
@property (nonatomic, copy) NSString *nm;
@property (nonatomic, copy) NSString *lv;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *recom;

@end

@interface LWAir : NSObject

@property (nonatomic, assign) NSInteger cityid;
@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cityaveragename;
@property (nonatomic, copy) NSString *lv;
@property (nonatomic, copy) NSString *pmtwoaqi;
@property (nonatomic, copy) NSString *pmtenaqi;
@property (nonatomic, copy) NSString *so2;
@property (nonatomic, copy) NSString *co;
@property (nonatomic, copy) NSString *no2;
@property (nonatomic, copy) NSString *o3;
@property (nonatomic, copy) NSString *aqigrade;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *ptime;

@end
