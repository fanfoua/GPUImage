//
//  SSwipeGroup.h
//  CXTouchMoveTest
//
//  Created by .Mr.SupEr on 15/7/16.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSwipe.h"

/*
 * SSwipeGroup
 * 表示所有的滑动，即所有手指从按下到抬起的操作
 * swipes滑动数组
 * num滑动数组长度
 */

@interface SSwipeGroup : NSObject

@property (nonatomic, strong) NSMutableArray *swipes;
@property (nonatomic, assign) int num;

@end
