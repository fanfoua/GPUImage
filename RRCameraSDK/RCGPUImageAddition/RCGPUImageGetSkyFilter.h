//
//  RCGPUImageGetSkyFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageGetSkyFilter : GPUImageFilter
{
    GLint avgBrightnessUniform;
    CGFloat avgBrightness;
}
-(id)initAvgBrightness:(CGFloat) brightness;
@end
