//
//  RCGPUImageFaceDermabrasionFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/5/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#ifndef RRCameraSDK_RCGPUImageFaceDermabrasionFilter_h
#define RRCameraSDK_RCGPUImageFaceDermabrasionFilter_h
#import "GPUImageFilterGroup.h"
@interface RCGPUImageFaceDermabrasionFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
//- (id)initImg:(UIImage *)image initGrayAve:(int *)grayAve;
- (id)initImg:(UIImage *)image Graythr:(int)graythr FaceWidth:(int)faceWidth;
@end
#endif
