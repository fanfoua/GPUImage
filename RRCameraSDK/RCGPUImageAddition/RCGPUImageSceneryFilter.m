//
//  RCGPUImageSceneryFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 淮静 on 15/3/25.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "RCGPUImageSceneryFilter.h"
#import "Modules/RCGPUImageUSMSharpeningFilter.h"
#import "Modules/RCGPUImageNaturalSaturationFilter.h"

@implementation RCGPUImageSceneryFilter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //USMSharpeningUSM锐化
    RCGPUImageUSMSharpeningFilter *USMSharpeningFilter = [[RCGPUImageUSMSharpeningFilter alloc] initCount:0.2 initRadius:6 initThreshold:0];
    [self addFilter:USMSharpeningFilter];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"HDR_ToneCurve1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [USMSharpeningFilter addTarget:ToneCurveFilter];
    
    //NaturalSaturation: +60
    RCGPUImageNaturalSaturationFilter *NaturalSaturationFilter = [[RCGPUImageNaturalSaturationFilter alloc] init];
    [(RCGPUImageNaturalSaturationFilter *) NaturalSaturationFilter setVibrance:(0.06f)];
    [self addTarget:NaturalSaturationFilter];
    [ToneCurveFilter addTarget:NaturalSaturationFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:USMSharpeningFilter,nil];
    self.terminalFilter = NaturalSaturationFilter;
    
    return self;
}
@end