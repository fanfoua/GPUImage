//
//  RCGPUImageOptionalColorsFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-20.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageOptionalColorsFilter : GPUImageFilter
{
    GLint colorUniform;
    GLint typeUniform;
    GLint fCUniform;
    GLint fMUniform;
    GLint fYUniform;
    GLint fBUniform;
}

@property(readwrite, nonatomic) GLint iColor;
@property(readwrite, nonatomic) GLint iType;
@property(readwrite, nonatomic) CGFloat fC;
@property(readwrite, nonatomic) CGFloat fM;
@property(readwrite, nonatomic) CGFloat fY;
@property(readwrite, nonatomic) CGFloat fB;

- (id)initColor:(GLint)color initType:(GLint)type initC:(NSInteger)iC initM:(NSInteger)iM initY:(NSInteger)iY initB:(NSInteger)iB;
@end
