//
//  RCGPUImageFaceMainFilter.h
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/8/18.
//  Copyright (c) 2015年 renren. All rights reserved.
//
#import "GPUImagePicture.h"
#import "GPUImageFilterGroup.h"
#import "RCFaceHistStatisticsFilter.h"
#import "RCStillImageFilter.h"
extern struct FACERECT g_FaceRect;
extern int graythr,faceWidth,grayAve;

@interface RCGPUImageFaceMainFilter : GPUImageFilterGroup
{
    GPUImagePicture* ImageSource1;
}
- (id)initImg:(UIImage *)image RRFaceParameters:(FaceParameters *)faceParameters;

+ (id)facePointImage:(unsigned char*)imgbuf FacePointRes:(FacePointData*)resultData ImageWidth:(int)w ImageHeight:(int)h ImageWidthStep:(int)widthStep ImageRotationType:(int)rotationType;
+ (id)facePointForImage:(UIImage*)imgbuf FacePointRes:(FacePointData*)resultData ImageRotationType:(int)rotationType;
+ (id)facePointReleaseModel;
@end
