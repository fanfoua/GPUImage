//
//  RCGPUImageLightLeakageFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageLightLeakageFilter.h"
#import "RCGPUImageNaturalSaturationFilter.h"

@implementation RCGPUImageLightLeakageFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }

    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];

    // image
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"LightLeakageMap_4" ofType:@"png"]];
    NSAssert(image, @"To use RCGPUImageCityLightFilter you need to add LightLeakageMap_4.png to your application bundle.");
    ImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageSoftLightBlendFilter *normalBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
    [self addFilter:normalBlendFilter];
    [ImageSource addTarget:normalBlendFilter atTextureLocation:1];
    [ImageSource processImage];

    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"LightLeakage_curve_3" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [normalBlendFilter addTarget:ToneCurveFilter];

    self.initialFilters = [NSArray arrayWithObjects:normalBlendFilter,nil];
    self.terminalFilter = ToneCurveFilter;
    return self;
}
@end
