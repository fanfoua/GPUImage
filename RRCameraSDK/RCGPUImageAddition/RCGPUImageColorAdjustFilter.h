//
//  RCGPUImageColorAdjustFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/2.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageColorAdjustFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
    GPUImagePicture *ImageSource2;
    GPUImagePicture *ImageSource3;
}
- (id)initOpacity:(CGFloat)opacity;
@end
