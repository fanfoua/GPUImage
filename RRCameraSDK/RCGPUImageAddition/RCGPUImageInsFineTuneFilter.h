//
//  RCGPUImageInsFineTuneFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/10.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

typedef struct
{
    //ins版本
     float brightness;//亮度
     float contrast;//对比度
     float saturation;//饱和度
     float temperature;//暖色？
     float vignette;//光影
    
     float fade;//褪色
     float highlights;
     float shadows;
     float sharpen;
     float sharpenDisabled;
     float tintShadowsIntensity;
     float tintHighlightsIntensity;
     GPUVector3 tintShadowsColor;
     GPUVector3 tintHighlightsColor;
    
    //自己版本
    float lux2;
    float vignetteEnd2;//暗角
    float sharpness2;//锐化
    float rotation2d2;//2d旋转
    float horizontalRotation3d2;//3d水平旋转
    float verticalRotation3d2;//3d垂直旋转
     //float tintShadowsColor[3];
     //float tintHighlightsColor[3];
}InsFineTune;

static float ga_Data[8][3];
@interface RCGPUImageInsFineTuneFilter : GPUImageFilter
{
    GLint brightnessUniform;
    GLint contrastUniform;
    GLint saturationUniform;
    GLint temperatureUniform;
    GLint vignetteUniform;
    GLint fadeUniform;
    GLint highlightsUniform;
    GLint shadowsUniform;
    GLint sharpenUniform;
    GLint sharpenDisabledUniform;
    GLint tintShadowsIntensityUniform;
    GLint tintHighlightsIntensityUniform;
    GLint tintShadowsColorUniform;
    GLint tintHighlightsColorUniform;
}

- (id)initStruct:(InsFineTune *)insFineTune;
@end
