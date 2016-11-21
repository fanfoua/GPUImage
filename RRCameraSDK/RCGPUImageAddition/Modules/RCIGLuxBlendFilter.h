//
//  RCIGLuxBlendFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/22.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

@interface RCIGLuxBlendFilter : GPUImageThreeInputFilter
{
    GLint luxBlendAmountUniform;
}

@property(readwrite, nonatomic) CGFloat luxBlendAmount;
@end