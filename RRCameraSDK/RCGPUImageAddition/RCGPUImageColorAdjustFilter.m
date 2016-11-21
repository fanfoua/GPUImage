//
//  RCGPUImageColorAdjustFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/2.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageColorAdjustFilter.h"
#import "Modules/RCGPUImageChangeColorHFilter.h"
#import "Modules/RCGPUImageNaturalSaturationOPTFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"
#import "Modules/RCGPUImageColorBalanceKeepBrightnessMainFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"

@implementation RCGPUImageColorAdjustFilter
- (id)initOpacity:(CGFloat)opacity;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"ColorAdjust1" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter1];
//    [ContrastFilter addTarget:ToneCurveFilter1];
    
    RCGPUImageChangeColorHFilter *ChangeColorHFilter=[[RCGPUImageChangeColorHFilter alloc]initAllImgH:0 RedH:0 GreenH:0 BlueH:-31 CyanH:0 MagentaH:0 YellowH:0];
    [self addFilter:ChangeColorHFilter];
    [ToneCurveFilter1 addTarget:ChangeColorHFilter];
    
    RCGPUImageColorBalanceKeepBrightnessMainFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessMainFilter alloc] initShadowShiftR:3 shadowShiftG:2 shadowShiftB:3 midShiftR:16 midShiftG:-4 midShiftB:-16 highlightShiftR:9 highlightShiftG:5 highlightShiftB:-4];
    [ChangeColorHFilter addTarget:ColorBalanceKeepBrightnessFilter];

//    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPTFilter=[[RCGPUImageNaturalSaturationOPTFilter alloc]initIratio:16];
//    [ColorBalanceKeepBrightnessFilter addTarget:NaturalSaturationOPTFilter];
    
    RCGPUImageSaturationOPTFilter *SaturationOPTFilter=[[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationOPTFilter setSaturation:(3)];
    [ColorBalanceKeepBrightnessFilter addTarget:SaturationOPTFilter];
    
    RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc] init];
    [(RCGPUImageContrastFilter *)ContrastFilter setContrast:86];
    [self addFilter:ContrastFilter];
    [SaturationOPTFilter addTarget:ContrastFilter];
    
    //Brightness:6
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:6.0];
    [self addFilter:BrightnessFilter];
    [ContrastFilter addTarget:BrightnessFilter atTextureLocation:0];
    
    
    //ToneCurve曲线 需要载入资源
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"ColorAdjust2" withExtension:@"acv"]];
    [BrightnessFilter addTarget:ToneCurveFilter2];
    
    //Opacity透明度
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];
    [self addFilter:OpacityFilter];
    [ToneCurveFilter2 addTarget:OpacityFilter];
    
    //NormalBlendFilter透明度贴图
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addTarget:NormalBlendFilter];
    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:ToneCurveFilter1,NormalBlendFilter, nil];
    self.terminalFilter = NormalBlendFilter;

    return self;
}
@end
