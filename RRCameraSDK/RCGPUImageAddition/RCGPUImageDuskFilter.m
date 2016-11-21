//
//  RCGPUImageDuskFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14/12/18.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageDuskFilter.h"
#import "Modules/RCGPUImageGradientMapFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"

@implementation RCGPUImageDuskFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //Contrast:92
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:21];
    [self addFilter:ContrastFilter];

    
    //Gradient Map渐变填充
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"duskgradientmap1_v5" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"duskgradientmap1_v5" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageDuskFilter you need to add duskgradientmap1_v5.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    RCGPUImageGradientMapFilter *GradientMapFilter1 = [[RCGPUImageGradientMapFilter alloc] init];
    [self addFilter:GradientMapFilter1];
    [ImageSource1 addTarget:GradientMapFilter1 atTextureLocation:1];
    [ImageSource1 processImage];
    [ContrastFilter addTarget:GradientMapFilter1];
    
    //Opacity: 0.5
    GPUImageOpacityFilter *OpacityFilter1 = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter1 setOpacity:(0.5f)];
    [self addFilter:OpacityFilter1];
    [GradientMapFilter1 addTarget:OpacityFilter1];
    
    //NormalBlendFilter
    GPUImageNormalBlendFilter *NormalBlendFilter1 = [[GPUImageNormalBlendFilter alloc] init];
    [self addFilter:NormalBlendFilter1];
    [ContrastFilter addTarget:NormalBlendFilter1 atTextureLocation:0];
    [OpacityFilter1 addTarget:NormalBlendFilter1 atTextureLocation:1];
    
    //ToneCurve1
//    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"dusk_color_curve1_v5" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                [RCDecrypt dealDecrypt:[resBundle URLForResource:@"dusk_color_curve1_v5" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    [NormalBlendFilter1 addTarget:ToneCurveFilter1];
    
    //ToneCurve2
//    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"dusk_color_curve2_v5" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"dusk_color_curve2_v5" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    self.initialFilters = [NSArray arrayWithObjects:ContrastFilter, nil];
    self.terminalFilter = ToneCurveFilter2;
    
    return self;
}

@end