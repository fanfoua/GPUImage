//
//  RCGPUImagea100Filter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/20.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImagea100Filter.h"
#import "Modules/RCGPUImageNaturalSaturationOPTFilter.h"
#import "Modules/RCGPUImageRGBCMYKSaturationFilter.h"
#import "Modules/RCGPUImageChangeColorHFilter.h"
#import "Modules/RCGPUImageChangeColorBrightnessFilter.h"
#import "Modules/RCGPUImageOptionalColorsFilter.h"
#import "RCGPUImageColorBalanceKeepBrightnessMainFilter.h"

@implementation RCGPUImagea100Filter
- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //NaturalSaturation:
    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTFilter alloc] initIratio:50];
    [self  addFilter:NaturalSaturationOPTFilter];
    
    RCGPUImageChangeColorHFilter *ChangeColorHFilter = [[RCGPUImageChangeColorHFilter alloc]initAllImgH:0 RedH:0 GreenH:0 BlueH:0 CyanH:0 MagentaH:0 YellowH:-11];
    [self addFilter:ChangeColorHFilter];
    [NaturalSaturationOPTFilter addTarget:ChangeColorHFilter];
    
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter = [[RCGPUImageRGBCMYKSaturationFilter alloc] initRed:0 initGreen:0 initBlue:0 initMagenta:0 initCyan:0 initYellow:-28];
    [self addFilter:RGBCMYKSaturationFilter];
    [ChangeColorHFilter addTarget:RGBCMYKSaturationFilter];
    
    RCGPUImageChangeColorBrightnessFilter *ChangeColorBrightnessFilter1 = [[RCGPUImageChangeColorBrightnessFilter alloc]initAllImgBrightness:0 RedBrightness:0 GreenBrightness:0 BlueBrightness:0 CyanBrightness:0 MagentaBrightness:0 YellowBrightness:21];
    [self addFilter:ChangeColorBrightnessFilter1];
    [RGBCMYKSaturationFilter addTarget:ChangeColorBrightnessFilter1];
    
    RCGPUImageChangeColorHFilter *ChangeColorHFilter2 = [[RCGPUImageChangeColorHFilter alloc]initAllImgH:0 RedH:0 GreenH:62 BlueH:0 CyanH:0 MagentaH:0 YellowH:0];
    [self addFilter:ChangeColorHFilter2];
    [ChangeColorBrightnessFilter1 addTarget:ChangeColorHFilter2];
    
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter2 = [[RCGPUImageRGBCMYKSaturationFilter alloc] initRed:0 initGreen:5 initBlue:0 initMagenta:0 initCyan:0 initYellow:0];
    [self addFilter:RGBCMYKSaturationFilter2];
    [ChangeColorHFilter2 addTarget:RGBCMYKSaturationFilter2];
    
    RCGPUImageChangeColorBrightnessFilter *ChangeColorBrightnessFilter2 = [[RCGPUImageChangeColorBrightnessFilter alloc]initAllImgBrightness:0 RedBrightness:0 GreenBrightness:-11 BlueBrightness:0 CyanBrightness:0 MagentaBrightness:0 YellowBrightness:0];
    [self addFilter:ChangeColorBrightnessFilter2];
    [RGBCMYKSaturationFilter2 addTarget:ChangeColorBrightnessFilter2];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"a100_1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [ChangeColorBrightnessFilter2 addTarget:ToneCurveFilter];
    
    RCGPUImageColorBalanceKeepBrightnessMainFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessMainFilter alloc] initShadowShiftR:0 shadowShiftG:0 shadowShiftB:0 midShiftR:3 midShiftG:0 midShiftB:0 highlightShiftR:11 highlightShiftG:0 highlightShiftB:0];
    [ToneCurveFilter addTarget:ColorBalanceKeepBrightnessFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:NaturalSaturationOPTFilter,nil];
    self.terminalFilter = ColorBalanceKeepBrightnessFilter;
    
    return self;
}

@end
