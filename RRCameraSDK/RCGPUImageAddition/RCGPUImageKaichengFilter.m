//
//  RCGPUImageKaichengFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/9.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageKaichengFilter.h"
#import "RCGPUImageOptionalColorsFilter.h"
#import "RCGPUImageRGBCMYKSaturationFilter.h"

@implementation RCGPUImageKaichengFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    
    //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter1 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:18 initM:0 initY:-25 initB:0];
    [self addFilter:OptionalColorsFilter1];
    
    //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:3 initType:1 initC:66 initM:16 initY:-60 initB:0];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter1 addTarget:OptionalColorsFilter2];
    
    //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter3 = [[RCGPUImageOptionalColorsFilter alloc] initColor:5 initType:1 initC:0 initM:0 initY:-34 initB:0];
    [self addFilter:OptionalColorsFilter3];
    [OptionalColorsFilter2 addTarget:OptionalColorsFilter3];
    
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter = [[RCGPUImageRGBCMYKSaturationFilter alloc] initRed:0 initGreen:0 initBlue:0 initMagenta:0 initCyan:0 initYellow:10];
    [self addFilter:RGBCMYKSaturationFilter];
    [OptionalColorsFilter3 addTarget:RGBCMYKSaturationFilter];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Kaicheng1" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    [RGBCMYKSaturationFilter addTarget:ToneCurveFilter1];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Kaicheng2" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    
    self.initialFilters = [NSArray arrayWithObjects:OptionalColorsFilter1,nil];
    self.terminalFilter = ToneCurveFilter2;
    
    return self;
}
@end
