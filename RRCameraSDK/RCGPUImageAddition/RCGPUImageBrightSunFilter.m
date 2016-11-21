//
//  RCGPUImageBrightSunFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageBrightSunFilter.h"
#import "Modules/RCGPUImageRGBCMYKSaturationFilter.h"
#import "RCGPUImageNaturalSaturationFilter.h"

@implementation RCGPUImageBrightSunFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];

    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"BrightSun_curve_4" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    
    //NaturalSaturation: +66
    RCGPUImageNaturalSaturationFilter *NaturalSaturationFilter = [[RCGPUImageNaturalSaturationFilter alloc] init];
    [(RCGPUImageNaturalSaturationFilter *) NaturalSaturationFilter setVibrance:(0.066f)];
    [self addFilter:NaturalSaturationFilter];
    [ToneCurveFilter addTarget:NaturalSaturationFilter];

    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter,nil];
    self.terminalFilter = NaturalSaturationFilter;
    
    return self;
}

@end
