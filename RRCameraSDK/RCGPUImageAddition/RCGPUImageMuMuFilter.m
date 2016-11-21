//
//  RCGPUImageMuMuFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/6.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageMuMuFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"
#import "Modules/RCGPUImageOptionalColorsFilter.h"

@implementation RCGPUImageMuMuFilter
- (id)initOpacity:(CGFloat)opacity;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    //Brightness:-10
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:-10.0];
    [self addFilter:BrightnessFilter];
    
    //Saturation: +13
    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(13)];
    [self addFilter:SaturationFilter];
    [BrightnessFilter addTarget:SaturationFilter];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MuMu1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter1];
    [SaturationFilter addTarget:ToneCurveFilter1];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MuMu2" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter3 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MuMu3" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter3];
    [ToneCurveFilter2 addTarget:ToneCurveFilter3];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter1 = [[RCGPUImageOptionalColorsFilter alloc] initColor:9 initType:0 initC:0 initM:0 initY:-2 initB:-1];
    [self addFilter:OptionalColorsFilter1];
    [ToneCurveFilter3 addTarget:OptionalColorsFilter1];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:8 initType:0 initC:-2 initM:0 initY:3 initB:0];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter1 addTarget:OptionalColorsFilter2];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter3 = [[RCGPUImageOptionalColorsFilter alloc] initColor:3 initType:0 initC:0 initM:0 initY:-21 initB:1];
    [self addFilter:OptionalColorsFilter3];
    [OptionalColorsFilter2 addTarget:OptionalColorsFilter3];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter5 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:0 initC:-5 initM:0 initY:0 initB:-1];
    [self addFilter:OptionalColorsFilter5];
    [OptionalColorsFilter3 addTarget:OptionalColorsFilter5];
    
    //SoftLightBlend: 柔光叠加
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                              pathForResource:@"MuMu4" ofType:@"png"]];
    NSAssert(image,
             @"To use RCGPUImageMuMuFilter you need to add MuMu4.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageSoftLightBlendFilter *SoftLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    [self addTarget:SoftLightBlendFilter];
    [ImageSource1 addTarget:SoftLightBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [OptionalColorsFilter5 addTarget:SoftLightBlendFilter];
    
    //Opacity透明度
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];
    [self addFilter:OpacityFilter];
    [SoftLightBlendFilter addTarget:OpacityFilter];
    
    //NormalBlendFilter透明度贴图
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addTarget:NormalBlendFilter];
    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];

    self.initialFilters = [NSArray arrayWithObjects:BrightnessFilter,NormalBlendFilter, nil];
    self.terminalFilter = NormalBlendFilter;
    
    return self;
}
@end
