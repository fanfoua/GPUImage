//
//  RCGPUImageAllisonColorFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/10.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageAllisonColorFilter.h"
#import "Modules/RCGPUImageColorBalanceKeepBrightnessMainFilter.h"
#import "Modules/RCGPUImageOptionalColorsFilter.h"

@implementation RCGPUImageAllisonColorFilter

-(id) init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"AllisonColor1" withExtension:@"acv"]];

    RCGPUImageColorBalanceKeepBrightnessMainFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessMainFilter alloc] initShadowShiftR:0 shadowShiftG:0 shadowShiftB:4 midShiftR:0 midShiftG:0 midShiftB:0 highlightShiftR:-5 highlightShiftG:0 highlightShiftB:0];
    [ToneCurveFilter addTarget:ColorBalanceKeepBrightnessFilter];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter1 = [[RCGPUImageOptionalColorsFilter alloc] initColor:9 initType:1 initC:-4 initM:-2 initY:0 initB:0];
    [self addFilter:OptionalColorsFilter1];
    [ColorBalanceKeepBrightnessFilter addTarget:OptionalColorsFilter1];
    
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:8 initType:1 initC:0 initM:0 initY:3 initB:-8];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter1 addTarget:OptionalColorsFilter2];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter3 = [[RCGPUImageOptionalColorsFilter alloc] initColor:7 initType:1 initC:0 initM:-2 initY:0 initB:0];
    [self addFilter:OptionalColorsFilter3];
    [OptionalColorsFilter2 addTarget:OptionalColorsFilter3];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter4 = [[RCGPUImageOptionalColorsFilter alloc] initColor:4 initType:1 initC:10 initM:0 initY:0 initB:0];
    [self addFilter:OptionalColorsFilter4];
    [OptionalColorsFilter3 addTarget:OptionalColorsFilter4];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter5 = [[RCGPUImageOptionalColorsFilter alloc] initColor:3 initType:1 initC:100 initM:-100 initY:-100 initB:15];
    [self addFilter:OptionalColorsFilter5];
    [OptionalColorsFilter4 addTarget:OptionalColorsFilter5];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter6 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:-10 initM:0 initY:0 initB:-35];
    [self addFilter:OptionalColorsFilter6];
    [OptionalColorsFilter5 addTarget:OptionalColorsFilter6];
    
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter7 = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:1 initC:-100 initM:-2 initY:-5 initB:-20];
    [self addFilter:OptionalColorsFilter7];
    [OptionalColorsFilter6 addTarget:OptionalColorsFilter7];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter, nil];
    self.terminalFilter = OptionalColorsFilter7;
    return self;
}
@end
