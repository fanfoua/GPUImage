//
//  RCGPUImageSlimmingFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/7.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface RCGPUImageSlimmingFilter : GPUImageFilterGroup
{
    GPUImagePicture *ImageSource1;
}
- (id)initPointOld:(CGPoint)pointOld PointNew:(CGPoint)pointNew Img:(UIImage*)image BrushW:(CGFloat)brushW;
@end
