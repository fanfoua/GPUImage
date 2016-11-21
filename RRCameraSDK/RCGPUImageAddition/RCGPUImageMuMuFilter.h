//
//  RCGPUImageMuMuFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/6.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageMuMuFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
- (id)initOpacity:(CGFloat)opacity;
@end
