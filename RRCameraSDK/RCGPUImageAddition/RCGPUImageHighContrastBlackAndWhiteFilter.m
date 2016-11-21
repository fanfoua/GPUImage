//
//  RCGPUImageHighContrastBlackAndWhiteFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/2.
//  Copyright (c) 2015年 renn. All rights reserved.
//
//高反差黑白
#import "RCGPUImageHighContrastBlackAndWhiteFilter.h"
#import "Modules/RCGPUImageNaturalSaturationOPTFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"


@implementation RCGPUImageHighContrastBlackAndWhiteFilter
- (id)initOpacity:(CGFloat)opacity;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
//    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter=[[RCGPUImageNaturalSaturationOPTFilter alloc]initIratio:13];
//    [self addTarget:NaturalSaturationOPTFilter];
    
    RCGPUImageSaturationOPTFilter *SaturationOPTFilter=[[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationOPTFilter setSaturation:(-100)];
    [self addFilter:SaturationOPTFilter];
//    [NaturalSaturationOPTFilter addTarget:SaturationOPTFilter];
    
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:70];
    [self addFilter:ContrastFilter];
    [SaturationOPTFilter addTarget:ContrastFilter];

    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"HighContrastBlackAndWhite1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter1];
    [ContrastFilter addTarget:ToneCurveFilter1];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"HighContrastBlackAndWhite2" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];

    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                                 pathForResource:@"HighContrastBlackAndWhite3" ofType:@"png"]];
//    UIImage *image = [UIImage imageWithData:[RCDecrypt dealDecrypt:
//                                             [resBundle URLForResource:@"HighContrastBlackAndWhite3" withExtension:@"png"]]];
    NSAssert(image,
             @"To use RCGPUImageHighContrastBlackAndWhiteFilter you need to add HighContrastBlackAndWhite3.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageSoftLightBlendFilter *SoftLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    [self addTarget:SoftLightBlendFilter];
    [ImageSource1 addTarget:SoftLightBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [ToneCurveFilter2 addTarget:SoftLightBlendFilter];
    
    //Opacity透明度
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];
    [self addFilter:OpacityFilter];
    [SoftLightBlendFilter addTarget:OpacityFilter];
    
    //NormalBlendFilter透明度贴图
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addTarget:NormalBlendFilter];
    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:SaturationOPTFilter,NormalBlendFilter, nil];
    self.terminalFilter = NormalBlendFilter;
    
    return self;
}
@end
