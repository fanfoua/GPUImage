//
//  RCGPUImageR001Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/10/22.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageR001Filter.h"

@implementation RCGPUImageR001Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R001_1" withExtension:@"acv"] mixturePercent:0.5];
//    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
//                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
//    //ToneCurve2
//        GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R001_2" withExtension:@"acv"] mixturePercent:0.5];
////    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVData:
////                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_2" withExtension:@"acv"]]];
//    [self addFilter:ToneCurveFilter2];
//    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = ToneCurveFilter1;
    
    return self;
}
@end
