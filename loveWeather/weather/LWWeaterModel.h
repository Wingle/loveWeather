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
@property (nonatomic, copy) NSString *date;         //日期
@property (nonatomic, copy) NSString *kn;           //天气描述，如：小小的雨滴，雨声细微，出行请注意路面湿滑
@property (nonatomic, copy) NSString *newkn;        //天气描述，如：小小的雨滴，雨声细微，出行请注意路面湿滑
@property (nonatomic, copy) NSString *wdir;         //风向，如：东北风
@property (nonatomic, copy) NSString *hwd;          //天气情况，如：小雨
@property (nonatomic, copy) NSString *lwd;          //天气情况，如：小雨
@property (nonatomic, copy) NSString *ltmp;         //最低气温
@property (nonatomic, copy) NSString *htmp;         //最高气温
@property (nonatomic, copy) NSString *hwid;         //未知
@property (nonatomic, copy) NSString *lwid;         //未知

@end

@interface LWCc : NSObject

@property (nonatomic, copy) NSString *gdt;          //日期
@property (nonatomic, copy) NSString *ldt;          //农历，如：甲午年二月十九
@property (nonatomic, copy) NSString *upt;          //发布时间
@property (nonatomic, copy) NSString *tmp;          //当前温度
@property (nonatomic, copy) NSString *htmp;         //最高气温
@property (nonatomic, copy) NSString *ltmp;         //最低气温
@property (nonatomic, copy) NSString *wd;           //天气情况，如：小雨
@property (nonatomic, copy) NSString *wid;          //未知
@property (nonatomic, copy) NSString *wl;           //风级，如：1级
@property (nonatomic, copy) NSString *wdir;         //风向，如：东北风
@property (nonatomic, copy) NSString *hum;          //湿度
@property (nonatomic, copy) NSString *sr;           //日出时间
@property (nonatomic, copy) NSString *ss;           //日落时间

@end

/*
 type="3" nm="化妆指数" lv="1" desc="保湿" recom="请选用保湿型霜类化妆品。"/>
 <idx type="5" nm="感冒指数" lv="4" desc="极易发" recom="强降温，天气寒冷，风力较强"/>
 <idx type="9" nm="洗车指数" lv="4" desc="不宜" recom="有雨，雨水和泥水会弄脏爱车。"/>
 <idx type="11" nm="穿衣指数" lv="4" desc="较冷" recom="建议着厚外套加毛衣等服装。"/>
 <idx type="12" nm="紫外线指数" lv="1" desc="最弱" recom="辐射弱，涂擦SPF8-12防晒护肤品。"/>
 <idx type="17" nm="运动指数" lv="4" desc="较不宜" recom="有降水，推荐您在室内进行休闲运动。"/>
 <idx type="19" nm="钓鱼指数
 */

@interface LWIdxs : NSObject

@property (nonatomic, assign) NSInteger type;       //类型，见上述说明
@property (nonatomic, copy) NSString *nm;           //类型说明
@property (nonatomic, copy) NSString *lv;           //指数
@property (nonatomic, copy) NSString *desc;         //描述
@property (nonatomic, copy) NSString *recom;        //意见

@end

/*
 <air cityid="340" cityName="上海" title="实时空气质量指数" cityaveragename="上海全城平均" lv="143" pmtwo="" pmten="" pmtwoaqi="143" pmtenaqi="101" so2="3" co="7" no2="24" o3="41" aqigrade="轻度污染" desc="今天上海空气属于轻度污染，过敏的朋友要小心哦，多洗手少外出！" content="" ptime="2014-03-19 14:00:00.0" androidadurl="http://static.adwo.com/ad/201401/lexy/index.html" androidaddesc="今天空气轻度污染，老人孩子尽量少出门，或佩戴专业口罩，莱克智净星空气净化器能智能检测、净化你家的空气哦！" sd="2014-01-17" ed="2014-03-28" st="00:01" et="23:59"/>
 */

@interface LWAir : NSObject

@property (nonatomic, assign) NSInteger cityid;                 //城市ID
@property (nonatomic, copy) NSString *cityName;                 //城市名字
@property (nonatomic, copy) NSString *title;                    //主题
@property (nonatomic, copy) NSString *cityaveragename;          //见上
@property (nonatomic, copy) NSString *lv;                       //PM2.5
@property (nonatomic, copy) NSString *pmtwoaqi;                 //PM2.5
@property (nonatomic, copy) NSString *pmtenaqi;                 //PM10
@property (nonatomic, copy) NSString *so2;                      //二氧化硫
@property (nonatomic, copy) NSString *co;                       //一氧化碳
@property (nonatomic, copy) NSString *no2;                      //二氧化碳
@property (nonatomic, copy) NSString *o3;                       //臭氧
@property (nonatomic, copy) NSString *aqigrade;                 //空气等级描述
@property (nonatomic, copy) NSString *desc;                     //建议
@property (nonatomic, copy) NSString *ptime;                    //发布时间

@end

/*
 <dws lupd="1386327123000">
 <dw id="23040" pt="2014/03/19 13:00" et="2014/03/19 19:00" desc="雷电黄色预警" info="上海市发布雷电黄色预警：预计6小时内可能发生雷电活动，可能会造成雷电灾害事故。防御指引：1、政府及相关部门按照职责做好防雷工作；2、密切关注天气，尽量避免户外活动。" icon="92" url=""/>
 </dws>
 */

@interface LWDw : NSObject

@property (nonatomic, assign) NSInteger wdid;                   //ID
@property (nonatomic, copy) NSString *icon;                     //图片
@property (nonatomic, copy) NSString *info;                     //信息
@property (nonatomic, copy) NSString *desc;                     //描述
@property (nonatomic, copy) NSString *pt;                       //发布时间
@property (nonatomic, copy) NSString *et;                       //终止时间

@end
