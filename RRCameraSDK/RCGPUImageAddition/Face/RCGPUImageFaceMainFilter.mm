//
//  RCGPUImageFaceMainFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/18.
//  Copyright (c) 2015年 renren. All rights reserved.
//
#import "RCGPUImageFaceMainFilter.h"
#import "RCGPUImageFaceInitFilter.h"
#import "RCGPUImageFaceDermabrasionFilter.h"
#import "RCGPUImageBrightnessFilter.h"
#import "RCGPUImageFaceLiftFilter.h"
#import "RCGPUImageEyeBiggerFilter.h"
#import "RCGPUImageEyeBeautyFilter.h"
#import "RCGPUImageSlimmingFilter.h"
#import "GPUImageSoftLightBlendFilter.h"
#import "RCGPUImageParaBlendFilter.h"
#import "FacePointDet/Nativeclass.h"

struct FACERECT g_FaceRect;
int graythr,faceWidth,grayAve;
UIImage *faceDermaImg=NULL;
@implementation RCGPUImageFaceMainFilter

- (id)initImg:(UIImage *)image RRFaceParameters:(FaceParameters *)faceParameters
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    CGImageRef img=[image CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal.width;
    int h = sizeReal.height;
    
    GPUImageOutput<GPUImageInput> *ga_imgfilter[10];
    GPUImageOutput<GPUImageInput> *ga_imgFirstAddfilter=nil;
    int indx=0;
    if (faceParameters->faceIsInit)
    {
        
        RCGPUImageFaceInitFilter * FaceInitFilter=[[RCGPUImageFaceInitFilter alloc] initImg:image Graythr:&graythr FaceWidth:&faceWidth GrayAve:&grayAve FaceRect:&g_FaceRect FaceParameter:faceParameters];
        
//        if (graythr==255)
//        {
//            faceParameters->faceIsGetFace=false;
//        }
//        else
//        {
//            faceParameters->faceIsGetFace=true;
//        }
        
        if (!faceParameters->faceIsGetFace)
        {
            graythr = 255;
            faceWidth=0;
        }
            GPUImageOutput<GPUImageInput> * filterOut =[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image Graythr:graythr FaceWidth:faceWidth];
            
            GPUImagePicture *sourcePicture1 = [[GPUImagePicture alloc] initWithImage:image];
            
            [sourcePicture1 addTarget:filterOut];
            
            [filterOut useNextFrameForImageCapture];
            [sourcePicture1 processImage];
        
            
            faceDermaImg = NULL;
            faceDermaImg = [filterOut imageFromCurrentFramebuffer];

        

        
        
        faceParameters->faceIsInit=false;
    }
    
    if (faceParameters->faceIsAkeybeauty)
    {
        faceParameters->faceIsDermabrasion=true;
        faceParameters->faceIsWhitening=true;
        faceParameters->faceIsLift=true;
        faceParameters->faceIsEyeBigger=true;
        faceParameters->faceIsEyeBeauty=true;
        faceParameters->faceDermabrasion=0.7*faceParameters->faceAkeybeauty;
        faceParameters->faceWhitening=0.5*faceParameters->faceAkeybeauty;
        faceParameters->faceLift=0.3*faceParameters->faceAkeybeauty;
        faceParameters->faceEyeBigger=0.3*faceParameters->faceAkeybeauty;
        faceParameters->faceEyeBeauty=0.2*faceParameters->faceAkeybeauty;
        faceParameters->faceIsAkeybeauty=false;
    }
    
    if (faceParameters->faceIsDermabrasion&&faceParameters->faceDermabrasion>0.0&&faceDermaImg!=NULL)
    {
//        RCGPUImageFaceDermabrasionFilter * FaceDermabrasionFilter=[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image Graythr:graythr FaceWidth:faceWidth];
//        
//        [self addFilter:FaceDermabrasionFilter];
//        ga_imgfilter[indx] = FaceDermabrasionFilter;
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//        indx++;
        
//        //Opacity透明度
//        GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
//        [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(faceParameters->faceDermabrasion)];
//        [self addFilter:OpacityFilter];
//        ga_imgfilter[indx] = OpacityFilter;
//        GPUImagePicture* ImageSource1 = [[GPUImagePicture alloc] initWithImage:faceDermaImg];
//        [ImageSource1 addTarget:OpacityFilter];
//        indx++;
//        [ImageSource1 processImage];
//
//        
//        //NormalBlendFilter
//        GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//        [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
        
        //ga_imgFirstAddfilter = NormalBlendFilter;
        
        RCGPUImageParaBlendFilter* paraBlendFilter = [[RCGPUImageParaBlendFilter alloc] initPara:faceParameters->faceDermabrasion];
        ImageSource1 = [[GPUImagePicture alloc] initWithImage:faceDermaImg];
        [ImageSource1 addTarget:paraBlendFilter atTextureLocation:1];
        [ImageSource1 processImage];
        ga_imgfilter[indx] = paraBlendFilter;
        indx++;
    }
    
//    if (faceParameters->faceIsDermabrasion&&faceParameters->faceDermabrasion>0.0)
//    {
//        RCGPUImageFaceDermabrasionFilter * FaceDermabrasionFilter=[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image Graythr:graythr FaceWidth:faceWidth];
//        
//        [self addFilter:FaceDermabrasionFilter];
//        ga_imgfilter[indx] = FaceDermabrasionFilter;
//        if (indx > 0)
//        {
//            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
//        }
//        indx++;
//        
//        //Opacity透明度
//        GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
//        [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(faceParameters->faceDermabrasion)];
//        [self addFilter:OpacityFilter];
//        [FaceDermabrasionFilter addTarget:OpacityFilter];
//        
//        //NormalBlendFilter
//        GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//        [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];
//        
//        ga_imgFirstAddfilter = NormalBlendFilter;
//        
//        ga_imgfilter[indx] = NormalBlendFilter;
//        indx++;
//    }
    
    if (faceParameters->faceIsWhitening&&faceParameters->faceWhitening>0.0)
    {
        CGFloat bright=50;
        if (grayAve>185)
        {
            bright=35;
        }
        bright=faceParameters->faceWhitening*bright;
        //Brightness:10
        RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
        [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:bright];
        [self addFilter:BrightnessFilter];
        ga_imgfilter[indx] = BrightnessFilter;
        if (indx > 0)
        {
            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
        }
        indx++;
    }
    
    //    if (faceParameters->faceIsLift&&faceParameters->faceIsGetFace&&faceParameters->faceLift>0.0)
    //    {
    //        RCGPUImageFaceLiftFilter *FaceLiftFilter = [[RCGPUImageFaceLiftFilter alloc]initFaceRect:&g_FaceRect ImgSize:&sizeReal Opacity:faceParameters->faceLift];
    //
    //        //if (FaceLiftFilter!=nil)
    //        {
    //            [self addFilter:FaceLiftFilter];
    //            ga_imgfilter[indx] = FaceLiftFilter;
    //            if (indx > 0)
    //            {
    //                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
    //            }
    //            indx++;
    //        }
    //    }
    
    if (faceParameters->faceIsLift&&faceParameters->faceLiftNum>0)
    {
        for (int k=0; k<faceParameters->faceLiftNum; k++)
        {
            if (faceParameters->faceIsGetFace&&faceParameters->faceLiftManual[k].model==0&&faceParameters->faceLiftManual[k].range>0.0)
            {
                RCGPUImageFaceLiftFilter *FaceLiftFilter = [[RCGPUImageFaceLiftFilter alloc]initFaceRect:&g_FaceRect ImgSize:&sizeReal Opacity:faceParameters->faceLiftManual[k].range];
                
                [self addFilter:FaceLiftFilter];
                ga_imgfilter[indx] = FaceLiftFilter;
                if (indx > 0)
                {
                    [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
                }
                indx++;
            }
            else if (faceParameters->faceLiftManual[k].model==1&&faceParameters->faceLiftManual[k].range>0.0)
            {
                RCGPUImageSlimmingFilter *SlimmingFilter = [[RCGPUImageSlimmingFilter alloc]initPointOld:faceParameters->faceLiftManual[k].poi1 PointNew:faceParameters->faceLiftManual[k].poi2 Img:image BrushW:faceParameters->faceLiftManual[k].range];
                [self addFilter:SlimmingFilter];
                ga_imgfilter[indx] = SlimmingFilter;
                if (indx > 0)
                {
                    [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
                }
                indx++;
            }
        }
        
    }
    
    //    if (faceParameters->faceIsEyeBigger&&faceParameters->faceIsGetFace&&faceParameters->faceEyeBigger>0.0)
    //    {
    //        RCGPUImageEyeBiggerFilter *EyeBiggerFilter = [[RCGPUImageEyeBiggerFilter alloc]initFaceRect:&g_FaceRect ImgSize:&sizeReal Opacity:faceParameters->faceEyeBigger];
    //
    //        [self addFilter:EyeBiggerFilter];
    //        ga_imgfilter[indx] = EyeBiggerFilter;
    //        if (indx > 0)
    //        {
    //            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
    //        }
    //        indx++;
    //    }
    
    if (faceParameters->faceIsEyeBigger)
    {
        struct FACERECT faceRectTes;
        for (int k=0; k<faceParameters->faceEyeBiggerNum; k++)
        {
            if (faceParameters->faceIsGetFace&&faceParameters->faceEyeBiggerManual[k].model==0&&faceParameters->faceEyeBiggerManual[k].range>0.0)
            {
                faceRectTes=g_FaceRect;
            }
            else if (faceParameters->faceEyeBiggerManual[k].model==1&&faceParameters->faceEyeBiggerManual[k].range>0.0)
            {
                faceRectTes.eyeleft_x=faceParameters->faceEyeBiggerManual[k].poi1.x;
                faceRectTes.eyeleft_y=faceParameters->faceEyeBiggerManual[k].poi1.y;
                faceRectTes.eyeright_x=0.0;
                faceRectTes.eyeright_y=0.0;
            }
            else
            {
                continue;
            }
            CGFloat rangeTm;
            if (faceParameters->faceEyeBiggerManual[k].model==1)
            {
                rangeTm=-faceParameters->faceEyeBiggerManual[k].range;
            }
            else
            {
                rangeTm=faceParameters->faceEyeBiggerManual[k].range;
            }
            RCGPUImageEyeBiggerFilter *EyeBiggerFilter = [[RCGPUImageEyeBiggerFilter alloc]initFaceRect:&faceRectTes ImgSize:&sizeReal Opacity:rangeTm];
            
            [self addFilter:EyeBiggerFilter];
            ga_imgfilter[indx] = EyeBiggerFilter;
            if (indx > 0)
            {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
        }
    }
    
    //    if (faceParameters->faceIsEyeBeauty&&faceParameters->faceIsGetFace&&faceParameters->faceEyeBeauty>0.0)
    //    {
    //        int Radius;
    //        if (faceWidth<100)
    //        {
    //            Radius=4;
    //        }
    //        if (faceWidth<140)
    //        {
    //            Radius=5;
    //        }
    //        else if (faceWidth<180)
    //        {
    //            Radius=6;
    //        }
    //        else if (faceWidth<250)
    //        {
    //            Radius=8;
    //        }
    //        else if(faceWidth<300)
    //        {
    //            Radius=10;
    //        }
    //        else
    //        {
    //            Radius=12;
    //        }
    //        Radius = Radius*1.35;
    //        RCGPUImageEyeBeautyFilter *EyeBeautyFilter = [[RCGPUImageEyeBeautyFilter alloc]initFaceRect:&g_FaceRect initImageSize:sizeReal initCount:0.75*faceParameters->faceEyeBeauty initRadius:Radius initThreshold:25];
    //
    //        ga_imgfilter[indx] = EyeBeautyFilter;
    //        if (indx > 0)
    //        {
    //            [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
    //        }
    //        indx++;
    //    }
    
    if (faceParameters->faceIsEyeBeauty)
    {
        struct FACERECT faceRectTes;
        for (int k=0; k<faceParameters->faceEyeBeautyNum; k++)
        {
            if (faceParameters->faceIsGetFace&&faceParameters->faceEyeBeautyManual[k].model==0&&faceParameters->faceEyeBeautyManual[k].range>0.0)
            {
                faceRectTes=g_FaceRect;
            }
            else if (faceParameters->faceEyeBeautyManual[k].model==1&&faceParameters->faceEyeBeautyManual[k].range>0.0)
            {
                faceRectTes.eyeleft_x=faceParameters->faceEyeBeautyManual[k].poi1.x;
                faceRectTes.eyeleft_y=faceParameters->faceEyeBeautyManual[k].poi1.y;
                faceRectTes.eyeright_x=0.0;
                faceRectTes.eyeright_y=0.0;
            }
            else
            {
                continue;
            }
            
            
            int Radius;
            if (faceWidth<100)
            {
                Radius=4;
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
            Radius = Radius*1.35;
            
            CGFloat rangeTm;
            if (faceParameters->faceEyeBeautyManual[k].model==1)
            {
                rangeTm=-0.15*faceParameters->faceEyeBeautyManual[k].range;
            }
            else
            {
                rangeTm=0.75*faceParameters->faceEyeBeautyManual[k].range;
            }
            RCGPUImageEyeBeautyFilter *EyeBeautyFilter = [[RCGPUImageEyeBeautyFilter alloc]initFaceRect:&faceRectTes initImageSize:sizeReal initCount:rangeTm initRadius:Radius initThreshold:25];
            
            ga_imgfilter[indx] = EyeBeautyFilter;
            if (indx > 0)
            {
                [ga_imgfilter[indx-1] addTarget:ga_imgfilter[indx]];
            }
            indx++;
        }
    }
    
    if (indx==0)
    {
        return nil;
    }
    
    self.initialFilters = [NSArray arrayWithObjects:ga_imgfilter[0],ga_imgFirstAddfilter,nil];
    self.terminalFilter = ga_imgfilter[indx-1];
    return self;
}



+ (id)facePointImage:(unsigned char*)imgbuf FacePointRes:(FacePointData*)resultData ImageWidth:(int)w ImageHeight:(int)h ImageWidthStep:(int)widthStep ImageRotationType:(int)rotationType
{
    FacePointInit();
    if (true)
    {
        faceTrackMain(imgbuf,resultData,w,h,widthStep,rotationType);
    }
    else
    {
        FacePointStart(imgbuf,resultData,w,h,widthStep,rotationType);
    }
    
    return self;
}
//单张图片检测
+ (id)facePointForImage:(UIImage*)imgbuf FacePointRes:(FacePointData*)resultData ImageRotationType:(int)rotationType
{
    CGImageRef img=[imgbuf CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal.width;
    int h = sizeReal.height;
    
    FacePointInit();
    FacePointStartForImg(imgbuf,resultData,w,h,w*4,rotationType);
    resultData->originWidth=w;
    resultData->originHeight=h;
    return self;
}

+ (id)facePointReleaseModel
{
    FacePointreleaseModel();
    return self;
}
@end
