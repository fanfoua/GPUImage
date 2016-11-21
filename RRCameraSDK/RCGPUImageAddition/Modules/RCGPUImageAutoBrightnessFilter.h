//
//  RCGPUImageAutoBrightnessFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-25.
//  Copyright (c) 2014年 renn. All rights reserved.
//

@interface RCGPUImageAutoBrightnessFilter : GPUImageFilter
{
    GLint brightnessUniform;
}

// Brightness ranges from 0 to 4.0, with 1.0 as the normal level
@property(readwrite, nonatomic) CGFloat brightness;

@end