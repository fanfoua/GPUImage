//
//  RCGPUImageP100Filter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/19.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageP100Filter.h"
#import "Modules/RCGPUImageNaturalSaturationOPTFilter.h"
#import "Modules/RCGPUImageRGBCMYKSaturationFilter.h"
#import "Modules/RCGPUImageChangeColorHFilter.h"
#import "Modules/RCGPUImageChangeColorBrightnessFilter.h"

@implementation RCGPUImageP100Filter

- (id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //NaturalSaturation:
    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTFilter alloc] initIratio:39];
    [self  addFilter:NaturalSaturationOPTFilter];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"P100_1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter];
    [NaturalSaturationOPTFilter addTarget:ToneCurveFilter];
    
    RCGPUImageChangeColorHFilter *ChangeColorHFilter = [[RCGPUImageChangeColorHFilter alloc]initAllImgH:0 RedH:0 GreenH:43 BlueH:0 CyanH:0 MagentaH:0 YellowH:0];
    [self addFilter:ChangeColorHFilter];
    [ToneCurveFilter addTarget:ChangeColorHFilter];
    
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter = [[RCGPUImageRGBCMYKSaturationFilter alloc] initRed:0 initGreen:24 initBlue:0 initMagenta:0 initCyan:0 initYellow:0];
    [self addFilter:RGBCMYKSaturationFilter];
    [ChangeColorHFilter addTarget:RGBCMYKSaturationFilter];
    
    RCGPUImageChangeColorBrightnessFilter *ChangeColorBrightnessFilter1 = [[RCGPUImageChangeColorBrightnessFilter alloc]initAllImgBrightness:0 RedBrightness:0 GreenBrightness:-10 BlueBrightness:0 CyanBrightness:0 MagentaBrightness:0 YellowBrightness:0];
    [self addFilter:ChangeColorBrightnessFilter1];
    [RGBCMYKSaturationFilter addTarget:ChangeColorBrightnessFilter1];
    
    RCGPUImageChangeColorBrightnessFilter *ChangeColorBrightnessFilter2 = [[RCGPUImageChangeColorBrightnessFilter alloc]initAllImgBrightness:0 RedBrightness:0 GreenBrightness:0 BlueBrightness:0 CyanBrightness:0 MagentaBrightness:0 YellowBrightness:33];
    [self addFilter:ChangeColorBrightnessFilter2];
    [ChangeColorBrightnessFilter1 addTarget:ChangeColorBrightnessFilter2];
    
    RCGPUImageChangeColorHFilter *ChangeColorHFilter3 = [[RCGPUImageChangeColorHFilter alloc]initAllImgH:0 RedH:0 GreenH:0 BlueH:-15 CyanH:0 MagentaH:0 YellowH:0];
    [self addFilter:ChangeColorHFilter3];
    [ChangeColorBrightnessFilter2 addTarget:ChangeColorHFilter3];
    
    RCGPUImageRGBCMYKSaturationFilter *RGBCMYKSaturationFilter3 = [[RCGPUImageRGBCMYKSaturationFilter alloc] initRed:0 initGreen:0 initBlue:25 initMagenta:0 initCyan:0 initYellow:0];
    [self addFilter:RGBCMYKSaturationFilter3];
    [ChangeColorHFilter3 addTarget:RGBCMYKSaturationFilter3];
    
    RCGPUImageChangeColorBrightnessFilter *ChangeColorBrightnessFilter3 = [[RCGPUImageChangeColorBrightnessFilter alloc]initAllImgBrightness:0 RedBrightness:0 GreenBrightness:0 BlueBrightness:22 CyanBrightness:0 MagentaBrightness:0 YellowBrightness:0];
    [self addFilter:ChangeColorBrightnessFilter3];
    [RGBCMYKSaturationFilter3 addTarget:ChangeColorBrightnessFilter3];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter,nil];
    self.terminalFilter = ChangeColorBrightnessFilter3;
    
    return self;
}

@end
