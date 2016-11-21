//
//  SSwipe.h
//  CXTouchMoveTest
//
//  Created by .Mr.SupEr on 15/7/16.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*
 * SSwipe
 * 表示一次滑动，即手指一次按下到抬起过程中的点坐标
 * swipeType滑动类型--0：涂抹；1：橡皮擦；
 * pointLine点数组
 * num点数组长度
 * width油画笔或者橡皮擦宽度（10~100）
 */

@interface SSwipe : NSObject

@property (nonatomic, assign) int swipeType;        // 0：涂抹  1：橡皮擦  2：图片涂抹1 3:图片涂抹 4:喷溅涂抹 5:马赛克涂抹
@property (nonatomic, strong) NSMutableArray *pointLine;   //CGPoint 数组
@property (nonatomic, assign) int num;              //点数组个数
@property (nonatomic, assign) int width;            //当前笔宽 （10~100）

@end
