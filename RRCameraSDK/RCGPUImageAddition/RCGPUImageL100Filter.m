//
//  RCGPUImageL100Filter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/20.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageL100Filter.h"
#import "Modules/RCGPUImageNaturalSaturationOPTFilter.h"
#import "Modules/RCGPUImageOptionalColorsFilter.h"

@implementation RCGPUImageL100Filter
- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];

    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"L100_1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    
    //OptionalColors可选颜色 0是相对 1是绝对  1是红 9是黑
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter3 = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:3 initM:11 initY:-30 initB:0];
    [self addFilter:OptionalColorsFilter3];
    [ToneCurveFilter addTarget:OptionalColorsFilter3];
    
    //NaturalSaturation:
    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTFilter alloc] initIratio:60];
    [self  addFilter:NaturalSaturationOPTFilter];
    [OptionalColorsFilter3 addTarget:NaturalSaturationOPTFilter];
    
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter,nil];
    self.terminalFilter = NaturalSaturationOPTFilter;
    
    return self;
}
@end
