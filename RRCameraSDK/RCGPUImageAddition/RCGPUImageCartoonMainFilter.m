//
//  RCGPUImageCartoonMainFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageCartoonMainFilter.h"
#import "RCGPUImageCartoonFilter.h"
#import "RCGPUImageSoftLightAlphaMaskBlendFilter.h"
#import "RCGPUImageGetSkyFilter.h"
#import "Modules/RCGPUImageSaturationOPTFilter.h"
#import "RRPhotoTransform.h"
#import "RCGPUImageGaussianBlurPassParamFilter.h"

@implementation RCGPUImageCartoonMainFilter

float getAvgBrightness(unsigned char* src, int width, int height,int channels)
{
    if (src ==0||width<=0||height<=0)
        return -1;
    if (channels!=3&&channels!=4)
        return -1;
    int n = width * height,i = 0;
    float avg = 0.0;
    for(i = 0; i < n * channels;i += channels)
    {
        avg += src[i+2];
    }
    avg /=n;
    return avg;
    
}

-(id)initOpacity:(CGFloat)opacity Img:(UIImage *)image;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    CGImageRef img=[image CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal.width;//image.size.width;
    int h = sizeReal.height;//image.size.height;

    unsigned char *imgPixel = RequestImagePixelsData(image);
    
    float avgBBrightness = getAvgBrightness(imgPixel,w,h,4);
    
    // 高斯
    RCGPUImageGaussianBlurPassParamFilter *blurFilter = [[RCGPUImageGaussianBlurPassParamFilter alloc] initRadius:1 initSigma:1.0];
    [self addFilter:blurFilter];
    
    RCGPUImageCartoonFilter *toonFilter1  = [[RCGPUImageCartoonFilter alloc] initThreshold:1.5 Amounts:20.0];
    [blurFilter addTarget:toonFilter1];
    
    GPUImageSoftLightBlendFilter *softLightBlendFilter=[[GPUImageSoftLightBlendFilter alloc]init];
    [toonFilter1 addTarget:softLightBlendFilter atTextureLocation:1];

    RCGPUImageGetSkyFilter *getSkyFilter = [[RCGPUImageGetSkyFilter alloc]initAvgBrightness:(avgBBrightness/255.0f)];
    
    
    RCGPUImageSoftLightAlphaMaskBlendFilter *softLightAlphaBlendFilterx = [[RCGPUImageSoftLightAlphaMaskBlendFilter alloc] initMixturePercent:1.0];
    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                              pathForResource:@"CartoonMain1" ofType:@"png"]];
    NSAssert(image1,
             @"To use RCGPUImageCartoonMainFilter you need to add CartoonMain1.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    
    [softLightBlendFilter addTarget:softLightAlphaBlendFilterx atTextureLocation:0];
    [ImageSource1 addTarget:softLightAlphaBlendFilterx atTextureLocation:1];
    [getSkyFilter addTarget:softLightAlphaBlendFilterx atTextureLocation:2];
    [ImageSource1 processImage];

    //Saturation: +10
    RCGPUImageSaturationOPTFilter *SaturationFilter = [[RCGPUImageSaturationOPTFilter alloc] init];
    [(RCGPUImageSaturationOPTFilter *) SaturationFilter setSaturation:(20)];
    [self addFilter:SaturationFilter];
    [softLightAlphaBlendFilterx addTarget:SaturationFilter];
    
    GPUImageToneCurveFilter *ToneCurveFilter1 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"CartoonMain2" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter1];
    [SaturationFilter addTarget:ToneCurveFilter1];
    
    GPUImageToneCurveFilter *ToneCurveFilter2 = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"CartoonMain3" withExtension:@"acv"]];
    [self addFilter:ToneCurveFilter2];
    [ToneCurveFilter1 addTarget:ToneCurveFilter2];
    
    //Opacity透明度
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];
    [self addFilter:OpacityFilter];
    [ToneCurveFilter2 addTarget:OpacityFilter];
    
    //NormalBlendFilter透明度贴图
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addTarget:NormalBlendFilter];
    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
    
    self.initialFilters = [NSArray arrayWithObjects:blurFilter,getSkyFilter,softLightBlendFilter,NormalBlendFilter, nil];
    self.terminalFilter = NormalBlendFilter;
    return  self;
}
@end
