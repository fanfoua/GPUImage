//
//  RCGPUImageRealFaceBeautyFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "RCGPUImageDermabrasionSimpleFilter.h"
#import "GPUImagePicture.h"

static float paraArrayTmp[256];
extern RCGPUImageDermabrasionSimpleFilter *defilter;
@interface RCGPUImageRealFaceBeautyFilter : GPUImageFilterGroup
{
    float fStep;
    int iRadius;
    
    GPUImagePicture *ImageSource1;
}
- (id)initOpacity:(CGFloat)opacity;
@end
