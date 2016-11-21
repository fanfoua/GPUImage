//
//  RCGPUImageBrightnessMapFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/14.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageBrightnessMapFilter : GPUImageTwoInputFilter
{
    GLint brightnessUniform;
}
@property(readwrite, nonatomic) CGFloat brightness;
@end
