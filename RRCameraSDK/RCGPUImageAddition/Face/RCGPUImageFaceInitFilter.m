//
//  RCGPUImageFaceInitFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/18.
//  Copyright (c) 2015年 renren. All rights reserved.
//

#import "RCGPUImageFaceInitFilter.h"
#import "RCFaceDetector.h"
#import "RCFaceHistStatisticsFilter.h"
#import "RRPhotoTransform.h"
#import "Nativeclass.h"

@implementation RCGPUImageFaceInitFilter

- (id)initImg:(UIImage *)image Graythr:(int*)p_pgraythr FaceWidth:(int *)p_pfaceWidth GrayAve:(int *)grayAve FaceRect:(struct FACERECT*)faceRectForLift FaceParameter:(FaceParameters *)faceParameters
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    CGImageRef img=[image CGImage];
    CGSize sizeReal = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    int w = sizeReal.width;
    int h = sizeReal.height;
    
    NSArray *pArray = [[RCFaceDetector alloc] setImage:image detectorAccuracy:RCDetectorAccuracyLow];
    
    if(faceParameters!=NULL)
    {
        int res = FacePointMain(image, &faceData);
        if (res == -1)
        {
            faceParameters->faceIsGetFace=false;
            return self;
        }
    }

    
    int ngraythrtmp;
    int graythr=255;
    int grayave=100;
    unsigned char *imgPixel = RequestImagePixelsData(image);
    
    if (imgPixel == NULL)
    {
        return nil;
    }
    
    facere.face_x=0;
    facere.face_y=0;
    facere.face_w=0;
    facere.face_h=0;
    int faceWidth = 0;
    
//    for (int i=0;i<faceData.faceCount;i++)
//    {
//        facere.face_x=faceData.rect[i].left;
//        facere.face_y=faceData.rect[i].top;
//        facere.face_w=faceData.rect[i].right-faceData.rect[i].left;
//        facere.face_h=faceData.rect[i].bottom-faceData.rect[i].top;
//        
//        if (facere.face_w>faceWidth)
//        {
//            faceRectForLift->face_x=model.bounds.origin.x+model.bounds.size.width*0.1;
//            faceRectForLift->face_y=model.bounds.origin.y+model.bounds.size.height*0.1;
//            faceRectForLift->face_w=model.bounds.size.width*0.8;
//            faceRectForLift->face_h=model.bounds.size.height*0.8;
//            
//            if (model.hasLeftEyePosition)
//            {
//                faceRectForLift->eyeleft_x=model.leftEyePosition.x;
//                faceRectForLift->eyeleft_y=model.leftEyePosition.y;
//            }
//            
//            if (model.hasRightEyePosition)
//            {
//                faceRectForLift->eyeright_x=model.rightEyePosition.x;
//                faceRectForLift->eyeright_y=model.rightEyePosition.y;
//            }
//        }
//        
//        faceWidth = max(facere.face_w,faceWidth);
//        F_GetFaceColorAndLight(imgPixel,w,h,&ngraythrtmp,&grayave);
//        
//        graythr=min(graythr, ngraythrtmp);
//    }
    if(faceParameters!=NULL)
    {
        faceParameters->faceIsGetFace=false;
    }
    
    for (RCFaceDetectorModel *model in pArray)
    {
        facere.face_x=model.bounds.origin.x+model.bounds.size.width*0.18;
        facere.face_y=model.bounds.origin.y+model.bounds.size.height*0.18;
        facere.face_w=model.bounds.size.width*0.64;
        facere.face_h=model.bounds.size.height*0.64;
        
        if (facere.face_w>faceWidth)
        {
            faceRectForLift->face_x=model.bounds.origin.x+model.bounds.size.width*0.1;
            faceRectForLift->face_y=model.bounds.origin.y+model.bounds.size.height*0.1;
            faceRectForLift->face_w=model.bounds.size.width*0.8;
            faceRectForLift->face_h=model.bounds.size.height*0.8;
            
            if (model.hasLeftEyePosition)
            {
                faceRectForLift->eyeleft_x=model.leftEyePosition.x;
                faceRectForLift->eyeleft_y=model.leftEyePosition.y;
            }
            
            if (model.hasRightEyePosition)
            {
                faceRectForLift->eyeright_x=model.rightEyePosition.x;
                faceRectForLift->eyeright_y=model.rightEyePosition.y;
            }
        }
        
        faceWidth = max(facere.face_w,faceWidth);
        F_GetFaceColorAndLight(imgPixel,w,h,&ngraythrtmp,&grayave);
        
        graythr=min(graythr, ngraythrtmp);
        
        if(faceParameters!=NULL)
        {
            faceParameters->faceIsGetFace=true;
        }
    }
    free(imgPixel);
    *grayAve=grayave;
    
    *p_pgraythr=graythr;
    *p_pfaceWidth=faceWidth;
    if(faceParameters!=NULL)
    {
        if (graythr==255)
        {
            faceParameters->faceIsGetFace=false;
        }
        else
        {
            faceParameters->faceIsGetFace=true;
        }
    }
    
    return self;
}
@end
