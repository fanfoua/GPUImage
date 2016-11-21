//
//  RCGPUImageLuxFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/26.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageLuxFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}

- (id)initWithPara:(UIImage *)image luxBlendAmount:(float)luxBlendAmount;

@end