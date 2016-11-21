//
//  RCGPUImageChangeColorBrightnessFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageChangeColorBrightnessFilter : GPUImageFilter
{
    GLint allImgBrightnessUniform;
    
    GLint redBrightnessUniform;
    GLint greenBrightnessUniform;
    GLint blueBrightnessUniform;
    
    GLint magentaBrightnessUniform;
    GLint cyanBrightnessUniform;
    GLint yellowBrightnessUniform;
}
@property(readwrite, nonatomic) CGFloat allImgBrightness;

@property(readwrite, nonatomic) CGFloat redBrightness;
@property(readwrite, nonatomic) CGFloat greenBrightness;
@property(readwrite, nonatomic) CGFloat blueBrightness;

@property(readwrite, nonatomic) CGFloat magentaBrightness;
@property(readwrite, nonatomic) CGFloat cyanBrightness;
@property(readwrite, nonatomic) CGFloat yellowBrightness;

- (id)initAllImgBrightness:(NSInteger)allImgBrightness RedBrightness:(NSInteger)redBrightness GreenBrightness:(NSInteger)greenBrightness BlueBrightness:(NSInteger)blueBrightness CyanBrightness:(NSInteger)cyanBrightness MagentaBrightness:(NSInteger)magentaBrightness YellowBrightness:(NSInteger)yellowBrightness;
@end
