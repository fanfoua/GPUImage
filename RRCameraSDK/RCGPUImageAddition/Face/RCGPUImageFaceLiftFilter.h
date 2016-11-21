//
//  RCGPUImageFaceLiftFilter
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/30.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "RCFaceHistStatisticsFilter.h"
#import "RCGPUImageFourInputFilter.h"
@interface RCGPUImageFaceLiftFilter : GPUImageFilterGroup
{
    GLint x1Uniform;
    GLint wUniform;
    GLint y1Uniform;
    GLint hUniform;
    
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
    GPUImagePicture *ImageSource4;
    GPUImagePicture *ImageSource5;
}
- (id)initFaceRect:(struct FACERECT*)faceRect ImgSize:(CGSize *)sizeReal Opacity:(CGFloat)opacity;
@end
