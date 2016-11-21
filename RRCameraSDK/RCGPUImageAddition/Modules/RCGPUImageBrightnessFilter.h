//
//  RCGPUImageBrightnessFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/27.
//  Copyright (c) 2015年 renn. All rights reserved.
//
#import "RCGPUImageBrightnessMapFilter.h"

@interface RCGPUImageBrightnessFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
    
    RCGPUImageBrightnessMapFilter *BrightnessMapFilter;
}

//brightness:[-150,150]
@property(readwrite, nonatomic) CGFloat brightness;

@end