//
//  RCGPUImageBlackWhiteFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageBlackWhiteFilter.h"

@implementation RCGPUImageBlackWhiteFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"BlackWhiteCurve_3" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    
    //Saturation: -100
    GPUImageSaturationFilter *SaturationFilter = [[GPUImageSaturationFilter alloc] init];
    [(GPUImageSaturationFilter *) SaturationFilter setSaturation:(0)];
    [self addFilter:SaturationFilter];
    [ToneCurveFilter addTarget:SaturationFilter];

    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter,nil];
    self.terminalFilter = SaturationFilter;
    
    return self;
}

@end
