//
//  RCGPUImageBlackWhiteStyleFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14/11/20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageBlackWhiteStyleFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"

@implementation RCGPUImageBlackWhiteStyleFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    //Saturation: -100
    GPUImageGrayscaleFilter *GrayscaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    [self addFilter:GrayscaleFilter];
    
    //ToneCurve
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                [RCDecrypt dealDecrypt:[resBundle URLForResource:@"BlackWhiteStyle_color_curve_v4" withExtension:@"acv"]]];

//    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"BlackWhiteStyle_color_curve_v4" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [GrayscaleFilter addTarget:ToneCurveFilter];
    
    //Brightness:10
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:10.0];
    [self addFilter:BrightnessFilter];
    [ToneCurveFilter addTarget:BrightnessFilter atTextureLocation:0];
    
    //Contrast:92
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:92.0];
    [self addFilter:ContrastFilter];
    [BrightnessFilter addTarget:ContrastFilter atTextureLocation:0];
    
    //ScreenBlend：滤色叠加
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"BlackWhiteStyle_OverlayMap1_10_v10" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"BlackWhiteStyle_OverlayMap1_10_v10" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageBlackWhiteStyleFilter you need to add BlackWhiteStyle_OverlayMap1_10_v10.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImageScreenBlendFilter *ScreenBlendFilter = [[GPUImageScreenBlendFilter alloc] init];
    [self addFilter:ScreenBlendFilter];
    [ImageSource1 addTarget:ScreenBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [ContrastFilter addTarget:ScreenBlendFilter];
    
    //OverlayBlendFilter, 叠加,通常用于创建阴影效果
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"BlackWhiteStyle_OverlayMap2" ofType:@"png"]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"BlackWhiteStyle_OverlayMap2" withExtension:@"png"]]];
    NSAssert(image2, @"To use RCGPUImageBlackWhiteStyleFilter you need to add BlackWhiteStyle_OverlayMap2.png to your application bundle.");
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    GPUImageOverlayBlendFilter *OverlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
    [self addFilter:OverlayBlendFilter];
    [ImageSource2 addTarget:OverlayBlendFilter atTextureLocation:1];
    [ImageSource2 processImage];
    [ScreenBlendFilter addTarget:OverlayBlendFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:GrayscaleFilter,nil];
    self.terminalFilter = OverlayBlendFilter;
    
    return self;
}

@end