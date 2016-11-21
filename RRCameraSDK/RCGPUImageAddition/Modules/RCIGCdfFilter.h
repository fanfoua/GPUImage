//
//  RCIGCdfFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/24.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCIGCdfFilter: NSObject

/**
 * @brief 照片亮度和饱和度优化处理
 * @param srcImage 处理前的图像
 * @param maxLen 按最大边等比例压缩
 * @return  处理后的图像
 */
+ (UIImage *) RCIGCdfFilter:(UIImage *) srcImage;

@end