//
//  LWTextView.m
//  loveWeather
//
//  Created by WingleWong on 14-3-31.
//  Copyright (c) 2014年 WingleWong. All rights reserved.
//

#import "LWTextView.h"

@implementation LWTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (BOOL)canBecameFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    // 事实上一个return NO就可以将系统的所有菜单项全部关闭了
    return NO;
}

@end
