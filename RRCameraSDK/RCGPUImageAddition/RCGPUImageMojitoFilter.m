//
//  RCGPUImageMojitoFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-28.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageMojitoFilter.h"
#import "Modules/RCGPUImageOptionalColorsFilter.h"
#import "Modules/RCGPUImageRGBCMYKSaturationFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"

@implementation RCGPUImageMojitoFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter1 = [[RCGPUImageOptionalColorsFilter alloc] initColor:9 initType:0 initC:-7 initM:13 initY:-4 initB:1];
    [self addFilter:OptionalColorsFilter1];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:8 initType:0 initC:-5 initM:-3 initY:-9 initB:3];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter1 addTarget:OptionalColorsFilter2];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter3 = [[RCGPUImageOptionalColorsFilter alloc] initColor:7 initType:0 initC:100 initM:-67 initY:-58 initB:5];
    [self addFilter:OptionalColorsFilter3];
    [OptionalColorsFilter2 addTarget:OptionalColorsFilter3];
    
    //ToneCurve曲线 需要载入资源
//    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Mojito_Tonecurve1_v10" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Mojito_Tonecurve1_v10" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter];
    [OptionalColorsFilter3 addTarget:ToneCurveFilter];
    
    //RGBCMYK Saturation Cyan+50
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter = [[RCGPUImageRGBCMYKSaturationFilter alloc] init];
    [(RCGPUImageRGBCMYKSaturationFilter *)RGBCMYKSaturationFilter setCyanSaturation:1.5f];
    [ToneCurveFilter addTarget:RGBCMYKSaturationFilter];
    
    //SoftLightBlend: 柔光叠加
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"MojitoSoftLightBlendMap1" ofType:@"png"]];
    UIImage *image = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"MojitoSoftLightBlendMap1" withExtension:@"png"]]];
    NSAssert(image, @"To use RCGPUImageMojitoFilter you need to add MojitoSoftLightBlendMap1.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageSoftLightBlendFilter *SoftLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    [self addTarget:SoftLightBlendFilter];
    [ImageSource1 addTarget:SoftLightBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [RGBCMYKSaturationFilter addTarget:SoftLightBlendFilter];
    
    //NaturalSaturation: 56  ——  Saturation: 15
    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(15)];
    [self addFilter:SaturationFilter];
    [SoftLightBlendFilter addTarget:SaturationFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:OptionalColorsFilter1,nil];
    self.terminalFilter = SaturationFilter;
    
    return self;
}
@end
