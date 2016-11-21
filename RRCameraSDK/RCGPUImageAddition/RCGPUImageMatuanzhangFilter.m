//
//  RCGPUImageMatuanzhangFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/12.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageMatuanzhangFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"
#import "RCGPUImageNaturalSaturationFilter.h"
#import "RCGPUImageNaturalSaturationOPTFilter.h"
#import "RCGPUImageSaturationOPTFilter.h"
#import "Modules/RCGPUImageColorBalanceKeepBrightnessMainFilter.h"
#import "RCGPUImageUSMSharpeningFilter.h"

@implementation RCGPUImageMatuanzhangFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MatuanzhangFilter1" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MatuanzhangFilter2" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter3 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"MatuanzhangFilter3" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter3];
    [ToneCurveFilter2 addTarget:ToneCurveFilter3];
    
    //5-Brightness:10
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:-7];
    [self addFilter:BrightnessFilter];
    [ToneCurveFilter3 addTarget:BrightnessFilter];
    
    //Contrast
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:72];
    [self addFilter:ContrastFilter];
    [BrightnessFilter addTarget:ContrastFilter];
    
//    //NaturalSaturation: +35
//    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTFilter alloc] initIratio:43];
//    [self addFilter:NaturalSaturationOPTFilter];
//    [ContrastFilter addTarget:NaturalSaturationOPTFilter];
    
    //Saturation: +10
    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(10)];
    [self addFilter:SaturationFilter];
    [ContrastFilter addTarget:SaturationFilter];
    
    RCGPUImageColorBalanceKeepBrightnessMainFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessMainFilter alloc] initShadowShiftR:1 shadowShiftG:1 shadowShiftB:9 midShiftR:7 midShiftG:4 midShiftB:-17 highlightShiftR:10 highlightShiftG:1 highlightShiftB:-9];
    [SaturationFilter addTarget:ColorBalanceKeepBrightnessFilter];

    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                                pathForResource:@"MatuanzhangFilter4" ofType:@"png"]];
    NSAssert(image1,
             @"To use RCGPUImageMatuanzhangFilter you need to add MatuanzhangFilter4.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];//生成图像资源
    
    //NormalBlendFilter透明度贴图
    GPUImageNormalBlendFilter *NormalBlendFilter1 = [[GPUImageNormalBlendFilter alloc] init];
    [self addFilter:NormalBlendFilter1];
    [ColorBalanceKeepBrightnessFilter addTarget:NormalBlendFilter1 atTextureLocation:0];
    [ImageSource1 addTarget:NormalBlendFilter1 atTextureLocation:1];
    [ImageSource1 processImage];
    
    GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    [(GPUImageSharpenFilter *)sharpenFilter setSharpness:(0.25f)];
    [NormalBlendFilter1 addTarget:sharpenFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = sharpenFilter;
    
    return self;
}

@end
