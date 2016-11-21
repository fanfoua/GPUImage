//
//  RCGPUImageWatermarkFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/13.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageWatermarkFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}

//blurRadiusInPixels = 0，不做处理
//blurRadiusInPixels （0,1]：模糊程度递增
//image为透明的水印图片，为nil时不加水印
- (id) initWithPara:(CGFloat)blurRadiusInPixels image:(UIImage *)image;

@end