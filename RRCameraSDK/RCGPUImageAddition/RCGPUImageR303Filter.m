//
//  RCGPUImageR303Filter.m
//  Renren-iOS-StickerCamera
//
//  Created by 0153-00503 on 15/10/22.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageR303Filter.h"

@implementation RCGPUImageR303Filter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    //GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"CartoonMain2" withExtension:@"acv"]];
    //ToneCurve1
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"R303_1" withExtension:@"acv"] mixturePercent:0.5];
    //    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVData:
    //                                                 [RCDecrypt dealDecrypt:[resBundle URLForResource:@"R001_1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter1];
    
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,nil];
    self.terminalFilter = ToneCurveFilter1;
    
    return self;
}
@end
