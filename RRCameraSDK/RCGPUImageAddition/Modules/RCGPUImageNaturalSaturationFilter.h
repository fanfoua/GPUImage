//
//  RCGPUImageNaturalSaturationFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14-9-25.
//  Copyright (c) 2014年 renn. All rights reserved.
//

@interface RCGPUImageNaturalSaturationFilter : GPUImageFilter
{
    GLint vibranceUniform;
}

// vibrance ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat vibrance;

@end