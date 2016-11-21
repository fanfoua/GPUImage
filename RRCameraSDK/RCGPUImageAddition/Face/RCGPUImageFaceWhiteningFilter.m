//
//  RCGPUImageFaceWhiteningFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/27.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageFaceWhiteningFilter.h"
#import "RCGPUImageOptionalColorsFilter.h"

@implementation RCGPUImageFaceWhiteningFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"FaceWhitening_curve_v1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    
//    //Contrast:10＝>除以2
//    
//    GPUImageContrastFilter *ContrastFilter = [[GPUImageContrastFilter alloc] init];
//    [(GPUImageContrastFilter *) ContrastFilter setContrast:(1.1)];
//    [self addTarget:ContrastFilter];
//    [ToneCurveFilter addTarget:ContrastFilter];
    
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:0 initM:5 initY:0 initB:-27];
    [self addFilter:OptionalColorsFilter];
    [ToneCurveFilter addTarget:OptionalColorsFilter];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:1 initC:0 initM:0 initY:0 initB:-38];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter addTarget:OptionalColorsFilter2];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter,nil];
    self.terminalFilter = OptionalColorsFilter2;
    
    return self;
}

@end
