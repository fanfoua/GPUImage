//
//  RRSceneryFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-8.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *   功能说明:
 *   完成照片亮度和饱和度优化处理
 **/
@interface RRSceneryFilter: NSObject


/**
 * @brief 照片亮度和饱和度优化处理
 * @param srcImage 处理前的图像
 * @param maxLen 按最大边等比例压缩
 * @return  处理后的图像
 */
+ (UIImage *) photoBrightnessAndSaturationFilter:(UIImage *) srcImage andMax:(NSInteger) maxLen;

@end

