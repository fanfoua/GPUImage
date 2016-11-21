//
//  RCGPUImageYearsV7Filter
//  RRCameraSDK
//
//  Created by 淮静 on 14/12/11.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageYearsV7Filter.h"

@implementation RCGPUImageYearsV7Filter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //OverlayBlendFilter, 叠加,通常用于创建阴影效果
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"Years_InnerMask100" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_InnerMask100" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageYearsV7Filter you need to add Years_InnerMask100.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImageOverlayBlendFilter *OverlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
    [self addTarget:OverlayBlendFilter];
    [ImageSource1 addTarget:OverlayBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];

    //ToneCurve1
//    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    [OverlayBlendFilter addTarget:ToneCurveFilter1];
    
    //ToneCurve2
//    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Years_color_curve2_v3" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve2_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    //ToneCurve3
//    GPUImageToneCurveFilter *ToneCurveFilter3 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Years_color_curve3_v3" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter3 = [[GPUImageToneCurveFilter alloc] initWithACVData:
                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve3_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter3];
    [ToneCurveFilter2 addTarget:ToneCurveFilter3];
    
    self.initialFilters = [NSArray arrayWithObjects:OverlayBlendFilter,nil];
    self.terminalFilter = ToneCurveFilter3;
    
    return self;
}

@end
