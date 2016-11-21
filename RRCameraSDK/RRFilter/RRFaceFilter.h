//
//  FaceFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14-7-21.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *   功能说明:
 *   完成照片磨皮和美白处理
 **/
@interface RRFaceFilter : NSObject


/**
 * @brief 图像美白处理
 * @param srcImage 处理前的图像
 * @param maxLen 按最大边等比例压缩
 * @return  处理后的图像
 */
+ (UIImage *) photoSmoothAndWhitenFilter:(UIImage *) srcImage andMax:(NSInteger) maxLen;

@end