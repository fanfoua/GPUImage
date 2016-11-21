//
//  RCGPUImageDaubFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/10.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"
#import "SFilter.h"

/*
 * SPoint
 * 描述图片上的点坐标x,y
 * (x,y)表示绝对坐标，左上角为(0,0),右下角为（width,height),width：原图宽;height：原图高
 */

//   CGPoint
//typedef struct tagSPoint
//{
//    int x;
//    int y;
//}SPoint;
//
///*
// * SSwipe
// * 表示一次滑动，即手指一次按下到抬起过程中的点坐标
// * swipeType滑动类型--0：涂抹；1：橡皮擦；
// * pointLine点数组
// * num点数组长度
// * width油画笔或者橡皮擦宽度（10~100）
// */
//typedef struct tagSSwipe
//{
//    int swipeType;
//    SPoint* pointLine;
//    int num;
//    int width;
//}SSwipe;
//
///*
// * SSwipeGroup
// * 表示所有的滑动，即所有手指从按下到抬起的操作
// * swipes滑动数组
// * num滑动数组长度
// */
//typedef struct tagSSwipeGroup
//{
//    SSwipe* swipes;
//    int num;
//}SSwipeGroup;
//
///*
// * SFilter
// * 涂抹滤镜参数
// * 操作类型--0：手指滑动；1：撤销；2：恢复
// * swipeGroup所有滑动操作
// */
//typedef struct tagSFilter
//{
//    int operaType;
//    SSwipeGroup swipeGroup;
//}SFilter;

@interface RCGPUImageDaubFilter : NSObject

+ (UIImage*)filterImg:(UIImage *)image SFilter:(SFilter*)sFilter;
+ (void)releaseImgPixel;
+ (UIImage*)exportImage:(UIImage*)image;

@end
