//
//  RCGPUImageContrastFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/27.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"
#import "RCGPUImageContrastMapFilter.h"

@interface RCGPUImageContrastFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;

    RCGPUImageContrastMapFilter *ContrastMapFilter;
}

//contrast:[-50,100]
@property(readwrite, nonatomic) CGFloat contrast;

@end