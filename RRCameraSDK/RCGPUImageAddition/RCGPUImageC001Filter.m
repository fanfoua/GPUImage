//
//  RCGPUImageC001Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/11/27.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageC001Filter.h"

@implementation RCGPUImageC001Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R001_1" withExtension:@"acv"] mixturePercent:0.5];
    [self addFilter:ToneCurveFilter1];
    
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R001_2" withExtension:@"acv"] mixturePercent:0.5];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    static int rand=0;
    
    if (rand>=2) {
        rand=0;
    }
    
    UIImage *image1;
    
    if (rand==0)
    {
        image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"1-01" ofType:@"png"]];
    }
    else if (rand==1)
    {
        image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                          pathForResource:@"1-02" ofType:@"png"]];
    }
    
    rand++;
    
    NSAssert(image1,
             @"To use RCGPUImageUnderExposureFilter you need to add UnderExposure_InnerMask100.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImageScreenBlendFilter *ScreenBlendFilter = [[GPUImageScreenBlendFilter alloc] init];
    [ImageSource1 addTarget:ScreenBlendFilter atTextureLocation:1];
    [ImageSource1 processImage];
    [ToneCurveFilter2 addTarget:ScreenBlendFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = ScreenBlendFilter;
    
    return self;
}

@end
