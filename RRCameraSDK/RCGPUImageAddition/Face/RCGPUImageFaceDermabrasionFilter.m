//
//  RCGPUImageFaceDermabrasionFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/7.
//  Copyright (c) 2015年 renn. All rights reserved.
//
#import "RCGPUImageFaceDermabrasionFilter.h"

#import "RCGPUImageDermabrasionFilter.h"
#import "RCGPUImageSelectFaceColorFilter.h"
#import "RCFaceHistStatisticsFilter.h"
#import "RCGPUImageFaceWhiteningFilter.h"

#import "RCGPUImageAutoContrastFilter.h"
#import "RCGPUImageBrightnessFilter.h"

#import "RCFaceDetector.h"
#import "RCFaceHistStatisticsFilter.h"
#import "RCGPUImageFaceBeautifyFilter.h"

#import "RRPhotoTransform.h"

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

@implementation RCGPUImageFaceDermabrasionFilter

UIImage* F_GetParaArray()
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
        paraArray[i]=max((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_2;
    MaxPara=PARA_3;
    MinGray=GRAY_2;
    MaxGray=GRAY_3;
    Sta=(GRAY_1+GRAY_2)/2;
    End=(GRAY_3+GRAY_4)/2;
    for (i=Sta; i<End; i++)
    {
        paraArray[i]=max((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_3;
    MaxPara=PARA_4;
    MinGray=GRAY_3;
    MaxGray=GRAY_4;
    Sta=(GRAY_2+GRAY_3)/2;
    End=(GRAY_4+GRAY_5)/2;
    for (i=Sta; i<End; i++)
    {
        paraArray[i]=max((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    MinPara=PARA_4;
    MaxPara=PARA_5;
    MinGray=GRAY_4;
    MaxGray=GRAY_5;
    Sta=(GRAY_4+GRAY_5)/2;
    End=(GRAY_5+GRAY_6)/2;
    for (i=Sta; i<End; i++)
    {
        paraArray[i]=max((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    
    MinPara=PARA_5;
    MaxPara=PARA_6;
    MinGray=GRAY_5;
    MaxGray=GRAY_6;
    Sta=(GRAY_5+GRAY_6)/2;
    End=256;
    for (i=Sta; i<End; i++)
    {
        paraArray[i]=max((MaxPara-MinPara)*(i-MinGray)/(MaxGray-MinGray)+MinPara,0.0001);
    }
    
    
    
    
    
    
    for (i=0; i<256; i++)
    {
        resultPixel[i*4]=paraArray[i]*2048;
    }
    
    
    
    //NSLog(@"God, RCIGCdfFilter time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
    UIImage *resultingImage = initImageWithPixel(resultPixel, 256, 1);

    
    
    return resultingImage;
}


- (id)initImg:(UIImage *)image Graythr:(int)graythr FaceWidth:(int)faceWidth //initGrayAve:(int *)grayAve
{
    if (!(self = [super init]))
    {
        return nil;
    }

//    int w = image.size.width;
//    int h = image.size.height;
//    NSArray *pArray = [[RCFaceDetector alloc] setImage:image detectorAccuracy:RCDetectorAccuracyLow];
//    
//    int ngraythrtmp;
//    int graythr=255;
//    int grayave=100;
//    unsigned char *imgPixel = RequestImagePixelsData(image);
//    
//    if (imgPixel == NULL)
//    {
//        return nil;
//    }
//    
//    facere.face_x=0;
//    facere.face_y=0;
//    facere.face_w=0;
//    facere.face_h=0;
//    int faceWidth = 0;
//    for (RCFaceDetectorModel *model in pArray)
//    {
//        facere.face_x=model.bounds.origin.x+model.bounds.size.width*0.18;
//        facere.face_y=model.bounds.origin.y+model.bounds.size.height*0.18;
//        facere.face_w=model.bounds.size.width*0.64;
//        facere.face_h=model.bounds.size.height*0.64;
//        faceWidth = max(facere.face_w,faceWidth);
//        F_GetFaceColorAndLight(imgPixel,image.size.width,image.size.height,&ngraythrtmp,&grayave);
//        
//        graythr=min(graythr, ngraythrtmp);
//    }
//    
//    *grayAve=grayave;
    

    
    if (graythr==255)
    {
        graythr=120;
    }
    graythr=max(graythr-10, 0);
    graythr=min(150, graythr);
    UIImage *paraImg = F_GetParaArray();
    RCGPUImageSelectFaceColorFilter *facecolorFilter = [[RCGPUImageSelectFaceColorFilter alloc] initGray:graythr];
    //[autoContrast addTarget:facecolorFilter];
    
    GPUImageClosingFilter *closeFilter = [[GPUImageClosingFilter alloc] initWithRadius:4];
    [facecolorFilter addTarget:closeFilter];
    
    int Radius;
    GLfloat thr;
    
    
    if (faceWidth<100)
    {
        Radius=3;
    }
    if (faceWidth<140)
    {
        Radius=5;
    }
    else if (faceWidth<180)
    {
        Radius=6;
    }
    else if (faceWidth<250)
    {
        Radius=8;
    }
    else if(faceWidth<300)
    {
        Radius=10;
    }
    else
    {
        Radius=12;
    }
    
    if (faceWidth==0)
    {
        Radius=4;
    }
    //自动对比度
//    RCGPUImageAutoContrastFilter *autoContrast = [[RCGPUImageAutoContrastFilter alloc] initImg:imgPixel initW:w initH:h initThr:0.01];
//    
//    free(imgPixel);
    
    //线性
    RCGPUImageDermabrasionFilter *defilter = [[RCGPUImageDermabrasionFilter alloc] initRadius:Radius initThreshold:0.02];
    //指数曲线
    //[autoContrast addTarget:defilter atTextureLocation:0];
    [closeFilter addTarget:defilter atTextureLocation:1];
    NSAssert(paraImg,
             @"To use RCGPUImageFaceDermabrasionFilter you need to add paraImg.png to your application bundle.");
     ImageSource1 = [[GPUImagePicture alloc] initWithImage:paraImg];
    [ImageSource1 addTarget:defilter atTextureLocation:2];
    [ImageSource1 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:defilter,facecolorFilter,nil];
    self.terminalFilter = defilter;
    
    return self;
}
@end
