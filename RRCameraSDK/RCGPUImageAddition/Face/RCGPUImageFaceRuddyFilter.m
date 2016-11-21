//
//  RCGPUImageFaceRuddyFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/6.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageFaceRuddyFilter.h"
#import "RCGPUImageNaturalSaturationOPTFilter.h"
#import "RCGPUImageOptionalColorsFilter.h"
#import "RCGPUImageBrightnessFilter.h"
#import "RCGPUImageFaceInitFilter.h"
#import "RCGPUImageFaceDermabrasionFilter.h"
#import "RCFaceHistStatisticsFilter.h"

@implementation RCGPUImageFaceRuddyFilter

- (id)initImg:(UIImage *)image
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    int grayAve;
//    RCGPUImageFaceDermabrasionFilter *FaceDermabrasionFilter = [[RCGPUImageFaceDermabrasionFilter alloc] initImg:image initGrayAve:&grayAve];
    
    int graythr,faceWidth,grayAve;
    struct FACERECT faceRect;
    RCGPUImageFaceInitFilter * FaceInitFilter=[[RCGPUImageFaceInitFilter alloc] initImg:image Graythr:&graythr FaceWidth:&faceWidth GrayAve:&grayAve FaceRect:&faceRect FaceParameter:NULL];
    
    RCGPUImageFaceDermabrasionFilter * FaceDermabrasionFilter=[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image Graythr:graythr FaceWidth:faceWidth];
    
    //ToneCurve曲线 需要载入资源
//    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"FaceRuddy1" withExtension:@"acv"]];
    GPUImageToneCurveFilter *ToneCurveFilter = [[GPUImageToneCurveFilter alloc] initWithACVData:[NSData dataWithContentsOfURL:[resBundle URLForResource:@"FaceRuddy1" withExtension:@"acv"]]];
    [self addFilter:ToneCurveFilter];
    [FaceDermabrasionFilter addTarget:ToneCurveFilter];
    
//    RCGPUImageNaturalSaturationOPTFilter *NaturalSaturationOPT = [[RCGPUImageNaturalSaturationOPTFilter alloc]initIratio:10];
//    [ToneCurveFilter addTarget:NaturalSaturationOPT];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:-28 initM:0 initY:-17 initB:-7];
    [self addFilter:OptionalColorsFilter];
    [ToneCurveFilter addTarget:OptionalColorsFilter];
    
    //OptionalColors可选颜色
    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:1 initC:-7 initM:-3 initY:-7 initB:-3];
    [self addFilter:OptionalColorsFilter2];
    [OptionalColorsFilter addTarget:OptionalColorsFilter2];

    
//    //OptionalColors可选颜色
//    RCGPUImageOptionalColorsFilter *OptionalColorsFilter = [[RCGPUImageOptionalColorsFilter alloc] initColor:2 initType:1 initC:-40 initM:0 initY:-25 initB:-10];
//    [self addFilter:OptionalColorsFilter];
//    [ToneCurveFilter addTarget:OptionalColorsFilter];
//    
//    //OptionalColors可选颜色
//    RCGPUImageOptionalColorsFilter *OptionalColorsFilter2 = [[RCGPUImageOptionalColorsFilter alloc] initColor:1 initType:1 initC:-10 initM:-5 initY:-10 initB:-5];
//    [self addFilter:OptionalColorsFilter2];
//    [OptionalColorsFilter addTarget:OptionalColorsFilter2];
    
//    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
//    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:5.0];
//    [OptionalColorsFilter2 addTarget:BrightnessFilter];
    
    //Brightness:10
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:5.0];
    [self addFilter:BrightnessFilter];
    [OptionalColorsFilter2 addTarget:BrightnessFilter atTextureLocation:0];

    
    
    //Contrast:10＝>除以2
    GPUImageContrastFilter *ContrastFilter = [[GPUImageContrastFilter alloc] init];
    [(GPUImageContrastFilter *) ContrastFilter setContrast:(1.05)];
    [self addTarget:ContrastFilter];
    [BrightnessFilter addTarget:ContrastFilter];
    
    
//    //Opacity透明度
//    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
//    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(0.8f)];
//    [self addFilter:OpacityFilter];
//    [ContrastFilter addTarget:OpacityFilter];
//    
//    //NormalBlendFilter
//    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//    //[self addTarget:NormalBlendFilter];
//    //[autoContrast addTarget:NormalBlendFilter atTextureLocation:0];
//    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];


    self.initialFilters = [NSArray arrayWithObjects:FaceDermabrasionFilter,nil];
    self.terminalFilter = ContrastFilter;
    
    return self;
}
@end
