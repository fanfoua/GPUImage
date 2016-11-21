//
//  RCGPUImageRealFaceBeautyFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageRealFaceBeautyFilter.h"
#import "RCGPUImageDermabrasionSimpleFilter.h"
#import "RRPhotoTransform.h"

RCGPUImageDermabrasionSimpleFilter *defilter=NULL;
//实时美颜
@implementation RCGPUImageRealFaceBeautyFilter
#define GRAY_1 40
#define PARA_1 0.01

#define GRAY_2 80
#define PARA_2 0.035

#define GRAY_3 110
#define PARA_3 0.07

#define GRAY_4 140
#define PARA_4 0.075



#define GRAY_5 220
#define PARA_5 0.07


#define GRAY_6 244
#define PARA_6 0.07


UIImage* F_GetParaArrayTmp()
{
    //    80 0.035
    //    180 0.06
    //    (x-0.035)/(i-80)=(0.06-0.035)/(180-80);
    int i;
    
    float MinPara,MaxPara,MinGray,MaxGray;
    int Sta,End;
    
    
    unsigned char *resultPixel = malloc(sizeof(unsigned char)*1*256*4);
    
    MinPara=PARA_1;
    MaxPara=PARA_2;
    MinGray=GRAY_1;
    MaxGray=GRAY_2;
    Sta=0;
    End=(GRAY_1+GRAY_2)/2;
    for (i=Sta; i<End; i++)
    {
        paraArrayTmp[i]=fmax((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_2;
    MaxPara=PARA_3;
    MinGray=GRAY_2;
    MaxGray=GRAY_3;
    Sta=(GRAY_1+GRAY_2)/2;
    End=(GRAY_3+GRAY_4)/2;
    for (i=Sta; i<End; i++)
    {
        paraArrayTmp[i]=fmax((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_3;
    MaxPara=PARA_4;
    MinGray=GRAY_3;
    MaxGray=GRAY_4;
    Sta=(GRAY_2+GRAY_3)/2;
    End=(GRAY_4+GRAY_5)/2;
    for (i=Sta; i<End; i++)
    {
        paraArrayTmp[i]=fmax((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_4;
    MaxPara=PARA_5;
    MinGray=GRAY_4;
    MaxGray=GRAY_5;
    Sta=(GRAY_4+GRAY_5)/2;
    End=(GRAY_5+GRAY_6)/2;
    for (i=Sta; i<End; i++)
    {
        paraArrayTmp[i]=fmax((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    
    MinPara=PARA_5;
    MaxPara=PARA_6;
    MinGray=GRAY_5;
    MaxGray=GRAY_6;
    Sta=(GRAY_5+GRAY_6)/2;
    End=256;
    for (i=Sta; i<End; i++)
    {
        paraArrayTmp[i]=fmax((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    for (i=0; i<256; i++)
    {
        resultPixel[i*4]=paraArrayTmp[i]*2048;
    }
    
    
    
    //NSLog(@"God, RCIGCdfFilter time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
    UIImage *resultingImage = initImageWithPixel(resultPixel, 256, 1);
    
    
    
    return resultingImage;
}

- (id)initOpacity:(CGFloat)opacity
{
    if (!(self = [super init]))
    {
        return nil;
    }

    UIImage *paraImg = F_GetParaArrayTmp();
    //线性
    RCGPUImageDermabrasionSimpleFilter *defilter = [[RCGPUImageDermabrasionSimpleFilter alloc] initRadius:12 initThreshold:0.02];
    //指数曲线
    //    RCGPUImageDermabrasionFilter *defilter = [[RCGPUImageDermabrasionFilter alloc] initRadius:10 initThreshold:0.03];
    NSAssert(paraImg,
             @"To use RCGPUImageFaceDermabrasionFilter you need to add paraImg.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:paraImg];
    [ImageSource1 addTarget:defilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    //Opacity透明度
    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(opacity)];
    [self addFilter:OpacityFilter];
    [defilter addTarget:OpacityFilter];
    
    //NormalBlendFilter
    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
    //[self addTarget:NormalBlendFilter];
    //[autoContrast addTarget:NormalBlendFilter atTextureLocation:0];
    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
    
    //    self.initialFilters = [NSArray arrayWithObjects:autoContrast,nil];
    //    self.terminalFilter = autoContrast;
    self.initialFilters = [NSArray arrayWithObjects:defilter,NormalBlendFilter,nil];
    
    self.terminalFilter = NormalBlendFilter;
    
    return self;
}
@end
