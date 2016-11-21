//
//  SFilter.h
//  CXTouchMoveTest
//
//  Created by .Mr.SupEr on 15/7/16.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSwipeGroup.h"

/*
 * SFilter
 * 涂抹滤镜参数
 * 操作类型--0：手指滑动；1：撤销；2：恢复
 * swipeGroup所有滑动操作
 */

@interface SFilter : NSObject

@property (nonatomic, assign) int operaType;
@property (nonatomic, strong) SSwipeGroup *swipeGroup;

@end
