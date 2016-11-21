//
//  RCGPUImageR402Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/10/22.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageR402Filter.h"

@implementation RCGPUImageR402Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R402_1" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"R402_2" ofType:@"png"]];
//    NSAssert(image1,
//             @"To use RCGPUImageR402Filter you need to add R402_2.png to your application bundle.");
//    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
//    GPUImageOverlayBlendFilter *OverlayBlendFilter = [[GPUImageOverlayBlendFilter alloc] init];
//    [self  addFilter:OverlayBlendFilter];
//    [ImageSource1 addTarget:OverlayBlendFilter atTextureLocation:1];
//    [ImageSource1 processImage];
//    [ToneCurveFilter1 addTarget:OverlayBlendFilter];
//    
//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"R402_3" ofType:@"png"]];
//    NSAssert(image2,
//             @"To use RCGPUImageR402Filter you need to add R402_3.png to your application bundle.");
//    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
//    GPUImageOverlayBlendFilter *OverlayBlendFilter2 = [[GPUImageOverlayBlendFilter alloc] init];
//    [self  addFilter:OverlayBlendFilter2];
//    [ImageSource2 addTarget:OverlayBlendFilter2 atTextureLocation:1];
//    [ImageSource2 processImage];
//    [OverlayBlendFilter addTarget:OverlayBlendFilter2];
//    
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                               pathForResource:@"R402_4" ofType:@"png"]];
//    NSAssert(image3,
//             @"To use RCGPUImageR402Filter you need to add R402_4.png to your application bundle.");
//    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
//    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//    [self  addFilter:NormalBlendFilter];
//    [ImageSource3 addTarget:NormalBlendFilter atTextureLocation:1];
//    [ImageSource3 processImage];
//    [OverlayBlendFilter2 addTarget:NormalBlendFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = ToneCurveFilter1;

    return self;
}
@end
