//
//  RCGPUImageBeautyEyeFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/4.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"
#import "RCGPUImageThreeInputFilter.h"
@interface RCGPUImageEyeBiggerFilter : GPUImageFilterGroup
{
    GLint x1Uniform;
    GLint y1Uniform;
    GLint x2Uniform;
    GLint y2Uniform;
    GLint rUniform;
    
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
    GPUImagePicture *ImageSource4;
    GPUImagePicture *ImageSource5;
}
- (id)initFaceRect:(struct FACERECT*)faceRect ImgSize:(CGSize *)sizeReal Opacity:(CGFloat)opacity;
@end
