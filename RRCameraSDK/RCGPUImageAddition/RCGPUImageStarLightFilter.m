//
//  RCGPUImageStarLightFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-21.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageStarLightFilter.h"
#import "RCGPUImageGradientMapFilter.h"

@implementation RCGPUImageStarLightFilter

- (id)init
{
    if (!(self = [super init]))
    {
		return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    //Vignette
    GPUImageVignetteFilter *VignetteFilter = [[GPUImageVignetteFilter alloc] init];
    [(GPUImageVignetteFilter *)VignetteFilter setVignetteEnd:(1.2f)];
    [self addTarget:VignetteFilter];
    
    //Brightness: 25
    GPUImageBrightnessFilter *BrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [(GPUImageBrightnessFilter *) BrightnessFilter setBrightness:(0.025f)];
    [self addFilter:BrightnessFilter];
    [VignetteFilter addTarget:BrightnessFilter];
    
    //ToneCurve
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"StarLight_color_curve" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [BrightnessFilter addTarget:ToneCurveFilter];

    //Gradient Map
    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"starLightGradientMap" ofType:@"png"]];
    NSAssert(image1,
             @"To use RCGPUImageStarLightFilter you need to add bstarLightGradientMap.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    RCGPUImageGradientMapFilter *GradientMapFilter = [[RCGPUImageGradientMapFilter alloc] init];
    [self addFilter:GradientMapFilter];
    [ImageSource1 addTarget:GradientMapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [ToneCurveFilter addTarget:GradientMapFilter];
    
    //Opacity
    GPUImageOpacityFilter *OpacityFilter1 = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter1 setOpacity:(0.20f)];
    [self addFilter:OpacityFilter1];
    [GradientMapFilter addTarget:OpacityFilter1];
    
    //NormalBlendFilter
    GPUImageNormalBlendFilter *NormalBlendFilter1 = [[GPUImageNormalBlendFilter alloc] init];
    [self addTarget:NormalBlendFilter1];
    [ToneCurveFilter addTarget:NormalBlendFilter1 atTextureLocation:0];
    [OpacityFilter1 addTarget:NormalBlendFilter1 atTextureLocation:1];
    
    //SoftLightBlend: 柔光叠加
    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"starLightOverlayMap1" ofType:@"png"]];
    NSAssert(image2,
             @"To use RCGPUImageStarLightFilter you need to add starLightOverlayMap1.png to your application bundle.");
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    GPUImageSoftLightBlendFilter *SoftLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    [self addTarget:SoftLightBlendFilter];
    [ImageSource2 addTarget:SoftLightBlendFilter atTextureLocation:1];
    [ImageSource2 processImage];
    [NormalBlendFilter1 addTarget:SoftLightBlendFilter];
    
    //Opacity
    GPUImageOpacityFilter *OpacityFilter2 = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter2 setOpacity:(1.0f)];
    [self addFilter:OpacityFilter2];
    [SoftLightBlendFilter addTarget:OpacityFilter2];

//    //NormalBlendFilter
//    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//    [self addTarget:NormalBlendFilter];
//    [OpacityFilter1 addTarget:NormalBlendFilter atTextureLocation:0];
//    [OpacityFilter2 addTarget:NormalBlendFilter atTextureLocation:1];

    //ScreenBlend：滤色叠加
    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"starLightOverlayMap2" ofType:@"png"]];
    NSAssert(image3,
             @"To use RCGPUImageStarLightFilter you need to add starLightOverlayMap2.png to your application bundle.");
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    GPUImageScreenBlendFilter *ScreenBlendFilter = [[GPUImageScreenBlendFilter alloc] init];
    [ImageSource3 addTarget:ScreenBlendFilter atTextureLocation:1];
    [ImageSource3 processImage];
    [OpacityFilter2 addTarget:ScreenBlendFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:VignetteFilter,nil];
    self.terminalFilter = ScreenBlendFilter;
    
    return self;
}

@end
