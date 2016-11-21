//
//  RCGPUImage2DRotateFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImage2DRotateFilter : GPUImageFilter
{
    GLint wDeUniform;
    GLint hDeUniform;
     GLint thetaUniform;
}

@property(readwrite, nonatomic) CGFloat theta;

@end