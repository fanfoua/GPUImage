//
//  RCGPUImageTotalTuneFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/1/9.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageTotalTuneFilter.h"
#import "Modules/RCGPUImageNaturalSaturationFilter.h"
#import "Modules/RCGPUImageBrightnessFilter.h"
#import "Modules/RCGPUImageContrastFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"
#import "Modules/RCIGBoxBlurFilter.h"
#import "RCGPUImageLuxFilter.h"
#import "RCGPUImageTotalRotateFilter.h"

@implementation RCGPUImageTotalTuneFilter

//- (id)initWithParameters:(float)lux
//              brightness:(float)brightness contrast:(float)contrast saturation:(float)saturation
//             temperature:(float)temperature highlight:(float)highlight shadow:(float)shadow
//               sharpness:(float)sharpness vignetteEnd:(float)vignetteEnd
//            isLinearOpen:(bool)isLinearOpen linearCenter:(float)linearCenter linearRadius:(float)linearRadius
//            isRadialOpen:(bool)isRadialOpen radialCenterX:(float)radialCenterX radialCenterY:(float)radialCenterY radialRadius:(float)radialRadius image:(UIImage *)image
- (id)initWithParameters:(InsFineTune*)insFineTune image:(UIImage*)image
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    GPUImageOutput<GPUImageInput> *ga_imgfilter[10];
    int indx = 0;
    
    float lux = insFineTune->lux2;
    float rotation2d = insFineTune->rotation2d2;
    float horizontalRotation3d = insFineTune->horizontalRotation3d2;
    float verticalRotation3d = insFineTune->verticalRotation3d2;
    float sharpness = insFineTune->sharpness2;
    float vignetteEnd = insFineTune->vignetteEnd2;
    
    //lux
    if (lux != 0.5) {
        RCGPUImageLuxFilter *LuxFilter = [[RCGPUImageLuxFilter alloc]
                                          initWithPara:image luxBlendAmount:2.0*(lux-0.5)];
        [self addFilter:LuxFilter];
        ga_imgfilter[indx] = LuxFilter;
        
        indx++;
    }
    
    //亮度、对比度、饱和度、色温暂时不用，使用的是ins的
//    //Brightness
//    if (brightness != 0.5)
//    {
//        RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc]
//                                                            initBrightness:75*(brightness-0.5)];
//        [self addFilter:BrightnessFilter];
//        ga_imgfilter[indx] = BrightnessFilter;
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//
//        indx++;
//    }
//    
//    //Contrast
//    if (contrast != 0.5)
//    {
//        RCGPUImageContrastFilter *ContrastFilter = [[RCGPUImageContrastFilter alloc]
//                                                                initContrast:50*(contrast-0.5)];
//        [self addFilter:ContrastFilter];
//        ga_imgfilter[indx] = ContrastFilter;
//        
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//
//        indx++;
//    }
//    
//    //Saturation
//    if (saturation != 0.5)
//    {
//        RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
//        [(RCGPUImageSaturationOPTFilter *)SaturationFilter setSaturation:0.9*(saturation-0.5) ];
//        [self addFilter:SaturationFilter];
//        ga_imgfilter[indx]=SaturationFilter;
//        
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//
//        indx++;
//    }
    
        //Rotation
        if (verticalRotation3d != 0.5)
        {
            //theta [-25, 25]
            int flag = -1;
            RCGPUImageTotalRotateFilter *TotalRotateFilter = [[RCGPUImageTotalRotateFilter alloc]
                                                          initPara:flag theta:50*(verticalRotation3d-0.5)];
            [self addFilter:TotalRotateFilter];
            ga_imgfilter[indx] = TotalRotateFilter;
    
            if (indx > 0)
            {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            
            indx++;
        }
    
    if (rotation2d != 0.5) {
        //theta [-25, 25]
        int flag = 0;
        RCGPUImageTotalRotateFilter *TotalRotateFilter = [[RCGPUImageTotalRotateFilter alloc]
                                                          initPara:flag theta:50*(rotation2d-0.5)];
        [self addFilter:TotalRotateFilter];
        ga_imgfilter[indx] = TotalRotateFilter;
        
        if (indx > 0)
        {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        
        indx++;
    }
    
    if (horizontalRotation3d != 0.5) {
        //theta [-25, 25]
        int flag = 1;
        RCGPUImageTotalRotateFilter *TotalRotateFilter = [[RCGPUImageTotalRotateFilter alloc]
                                                          initPara:flag theta:50*(horizontalRotation3d-0.5)];
        [self addFilter:TotalRotateFilter];
        ga_imgfilter[indx] = TotalRotateFilter;
        
        if (indx > 0)
        {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        
        indx++;
    }
    
    
//    //WhiteBalance
//    if(temperature != 0.5)
//    {
//        GPUImageWhiteBalanceFilter *WhiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
//        //range from 3125 to 6875,with 5000 as the normal level
//        [(GPUImageWhiteBalanceFilter *)WhiteBalanceFilter setTemperature:((temperature*3750)+3125)];
//        [self addFilter:WhiteBalanceFilter];
//        ga_imgfilter[indx]=WhiteBalanceFilter;
//        
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//        
//        indx++;
//    }
    
//    //Highlight高光和阴影暂时不用
//    if (highlight!=0.0||shadow!=0.0)
//    {
//        GPUImageHighlightShadowFilter *HighlightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
//        //0.2 - 1, decrease to darken highlights. @default 1
//        [(GPUImageHighlightShadowFilter *)HighlightShadowFilter setHighlights:1.0-highlight*0.8];
//        //0 - 1, increase to lighten shadows, @default 0
//        [(GPUImageHighlightShadowFilter *)HighlightShadowFilter setShadows:shadow];
//        [self addFilter:HighlightShadowFilter];
//        ga_imgfilter[indx]=HighlightShadowFilter;
//        
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//        
//        indx++;
//    }
    
//    //hue
//    GPUImageHueFilter *HueFilter = [[GPUImageHueFilter alloc] init];
//    [(GPUImageHueFilter *)HueFilter setHue:360.0*hue];
//    [self addFilter:HueFilter];
//    [HighlightShadowFilter addTarget:HueFilter];
    
    //sharpen
    if (sharpness!=0.0)
    {
        GPUImageSharpenFilter *SharpenFilter = [[GPUImageSharpenFilter alloc] init];
        [(GPUImageSharpenFilter *)SharpenFilter setSharpness:0.6*sharpness];
        [self addFilter:SharpenFilter];
        //[HighlightShadowFilter addTarget:SharpenFilter];
        ga_imgfilter[indx]=SharpenFilter;
        
        if (indx > 0)
        {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        
        indx++;
    }

    //Vignette
    if (vignetteEnd!=0.0)
    {
        GPUImageVignetteFilter *VignetteFilter = [[GPUImageVignetteFilter alloc] init];
        //_vignetteEnd: [0.8, 3.0]
        [(GPUImageVignetteFilter *)VignetteFilter setVignetteEnd:(3.0-2.2*sqrt(vignetteEnd))];
        [self addFilter:VignetteFilter];
        //[SharpenFilter addTarget:VignetteFilter];
        ga_imgfilter[indx]=VignetteFilter;
       
        if (indx > 0)
        {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        
        indx++;
    }
    
    if (indx == 0) {
        return nil;
    }
    
    self.initialFilters = [NSArray arrayWithObjects:ga_imgfilter[0],nil];
    self.terminalFilter = ga_imgfilter[indx-1];


//    if ((!isLinearOpen && !isRadialOpen) ||
//        (isLinearOpen && isRadialOpen) //exception
//        )
//    {
        //self.terminalFilter = VignetteFilter;
    
 //   }
//    else if (isLinearOpen && !isRadialOpen)
//    {
//        //TiltShift
//        GPUImageTiltShiftFilter *TiltShiftFilter = [[GPUImageTiltShiftFilter alloc] init];
//        [(GPUImageTiltShiftFilter *)TiltShiftFilter setTopFocusLevel:linearCenter - 0.15*linearRadius];
//        [(GPUImageTiltShiftFilter *)TiltShiftFilter setBottomFocusLevel:linearCenter + 0.15*linearRadius];
//        [(GPUImageTiltShiftFilter *)TiltShiftFilter setFocusFallOffRate:0.3];
//        [self addFilter:TiltShiftFilter];
//        [VignetteFilter addTarget:TiltShiftFilter];
//        
//        self.terminalFilter = TiltShiftFilter;
//    }
//    else if (!isLinearOpen && isRadialOpen)
//    {
//        //GaussianSelectiveBlur
//        GPUImageGaussianSelectiveBlurFilter *GaussianSelectiveBlurFilter = [[GPUImageGaussianSelectiveBlurFilter alloc] init];
//        [(GPUImageGaussianSelectiveBlurFilter *)GaussianSelectiveBlurFilter setExcludeBlurSize:(40+radialRadius*200)/320.0];
//        [(GPUImageGaussianSelectiveBlurFilter *)GaussianSelectiveBlurFilter setExcludeCircleRadius:(60+radialRadius*200)/320.0];
//        [(GPUImageGaussianSelectiveBlurFilter *)GaussianSelectiveBlurFilter setExcludeCirclePoint:(CGPointMake(radialCenterX, radialCenterY))];
//        [self addFilter:GaussianSelectiveBlurFilter];
//        [VignetteFilter addTarget:GaussianSelectiveBlurFilter];
//        
//        self.terminalFilter = GaussianSelectiveBlurFilter;
//    }

    return self;
}

@end