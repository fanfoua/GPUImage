//
//  RCGPUImageQiujianingFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/9.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageQiujianingFilter.h"
#import "RCGPUImageColorBalanceKeepBrightnessMainFilter.h"
#import "RCGPUImageSaturationOPTFilter.h"

@implementation RCGPUImageQiujianingFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Qiujianing1" withExtension:@"acv"]];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"Years_color_curve1_v3" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
    
    RCGPUImageColorBalanceKeepBrightnessMainFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessMainFilter alloc] initShadowShiftR:0 shadowShiftG:0 shadowShiftB:0 midShiftR:5 midShiftG:10 midShiftB:5 highlightShiftR:0 highlightShiftG:0 highlightShiftB:0];
    [ToneCurveFilter1 addTarget:ColorBalanceKeepBrightnessFilter];
    
    //Saturation: +10
    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(-20)];
    [self addFilter:SaturationFilter];
    [ColorBalanceKeepBrightnessFilter addTarget:SaturationFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = SaturationFilter;
    
    return self;
}

@end
