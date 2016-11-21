//
//  RCGPUImageHighContrastBlackAndWhiteFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/2.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageHighContrastBlackAndWhiteFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
- (id)initOpacity:(CGFloat)opacity;
@end
