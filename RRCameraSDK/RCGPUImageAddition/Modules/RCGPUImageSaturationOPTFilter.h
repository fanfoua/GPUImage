//
//  RCGPUImageSaturationOPTFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-3-18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageSaturationOPTFilter : GPUImageFilter
{
    GLint saturationUniform;
}

//[-1.0,1.0]
@property(readwrite, nonatomic) CGFloat saturation;
@end