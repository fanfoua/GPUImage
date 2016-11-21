//
//  RCIGBoxBlurFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/22.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCIGBoxBlurFilter : GPUImageFilter
{
    GLint kernelSizeUniform;
    GLint blurVectorUniform;
}

@property(readwrite, nonatomic) CGFloat kernelSize;
@property(readwrite, nonatomic) CGPoint blurVector;

@end