//
//  RCGPUImageCartoonMainFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageCartoonMainFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
-(id)initOpacity:(CGFloat)opacity Img:(UIImage *)image;
@end
