//
//  RCGPUImage3DRotationFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/9.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImage3DRotationFilter : GPUImageFilter
{
    GLint a11Uniform;
    GLint a12Uniform;
    GLint a13Uniform;
    GLint a21Uniform;
    GLint a22Uniform;
    GLint a23Uniform;
    GLint a31Uniform;
    GLint a32Uniform;
}

@property(readwrite, nonatomic) GLfloat a11;
@property(readwrite, nonatomic) GLfloat a12;
@property(readwrite, nonatomic) GLfloat a13;
@property(readwrite, nonatomic) GLfloat a21;
@property(readwrite, nonatomic) GLfloat a22;
@property(readwrite, nonatomic) GLfloat a23;
@property(readwrite, nonatomic) GLfloat a31;
@property(readwrite, nonatomic) GLfloat a32;

- (id)initPara:(int)flag theta:(float)theta;

@end