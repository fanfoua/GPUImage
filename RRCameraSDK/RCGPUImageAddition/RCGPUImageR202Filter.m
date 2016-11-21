//
//  RCGPUImageR202Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/10/22.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageR202Filter.h"

@implementation RCGPUImageR202Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R202_1" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"R202_2" ofType:@"png"]];
//    NSAssert(image1,
//             @"To use RCGPUImageR202Filter you need to add R202_2.png to your application bundle.");
//    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
//    GPUImageOverlayBlendFilter *OverlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
//    [self  addFilter:OverlayBlendFilter];
//    [ImageSource1 addTarget:OverlayBlendFilter atTextureLocation:1];
//    [ImageSource1 processImage];
//    [ToneCurveFilter1 addTarget:OverlayBlendFilter];
//    
//    //SoftLightBlend: 柔光叠加
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                              pathForResource:@"R202_3" ofType:@"png"]];
//    NSAssert(image2,
//             @"To use RCGPUImageR202Filter you need to add R202_3.png to your application bundle.");
//    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
//    GPUImageSoftLightBlendFilter *SoftLightBlendFilter = [[GPUImageSoftLightBlendFilter alloc] init];
//    [self addFilter:SoftLightBlendFilter];
//    [ImageSource2 addTarget:SoftLightBlendFilter atTextureLocation:1];
//    [ImageSource2 processImage];
//    [OverlayBlendFilter addTarget:SoftLightBlendFilter];
    
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = ToneCurveFilter1;
    
    return self;
}

@end
