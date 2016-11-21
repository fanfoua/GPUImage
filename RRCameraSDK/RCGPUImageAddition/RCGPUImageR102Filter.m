//
//  RCGPUImageR102Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/10/22.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageR102Filter.h"
#import "RCGPUImageNaturalSaturationOPTFilter.h"
#import "RCGPUImageSaturationOPTFilter.h"

@implementation RCGPUImageR102Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R102_1" withExtension:@"acv"]mixturePercent:0.5];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
    //NaturalSaturation: +30
    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTFilter alloc] initIratio:-30];
    [self  addFilter:NaturalSaturationOPTFilter];
    [ToneCurveFilter1 addTarget:NaturalSaturationOPTFilter];
    
//    //Saturation: +10
//    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
//    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(5)];
//    [self addFilter:SaturationFilter];
//    [NaturalSaturationOPTFilter addTarget:SaturationFilter];
    
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = NaturalSaturationOPTFilter;
    
    return self;
}
@end
