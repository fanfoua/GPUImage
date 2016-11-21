//
//  RCGPUImageRGBCMYKSaturationFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 14/11/28.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

/** Adjusts the saturation of an image
 */
@interface RCGPUImageRGBCMYKSaturationFilter : GPUImageFilter
{
    GLint redSaturationUniform;
    GLint greenSaturationUniform;
    GLint blueSaturationUniform;
    
    GLint magentaSaturationUniform;
    GLint cyanSaturationUniform;
    GLint yellowSaturationUniform;
}

/** Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
 */
@property(readwrite, nonatomic) CGFloat redSaturation;
@property(readwrite, nonatomic) CGFloat greenSaturation;
@property(readwrite, nonatomic) CGFloat blueSaturation;

@property(readwrite, nonatomic) CGFloat magentaSaturation;
@property(readwrite, nonatomic) CGFloat cyanSaturation;
@property(readwrite, nonatomic) CGFloat yellowSaturation;

- (id)initRed:(NSInteger)red initGreen:(NSInteger)green initBlue:(NSInteger)blue initMagenta:(NSInteger)magenta initCyan:(NSInteger)cyan initYellow:(NSInteger)yellow;
@end