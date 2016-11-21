//
//  RCGPUImageRotate90Filter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageRotate90Filter : GPUImageFilter
{
    GLint flagUniform;
}

@property(readwrite, nonatomic) GLint flag;

@end