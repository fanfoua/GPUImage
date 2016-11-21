//
//  RCGPUImageSoftLightAlphaMaskBlendFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/8.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "RCGPUImageFourInputFilter.h"
@interface RCGPUImageSoftLightAlphaMaskBlendFilter :GPUImageThreeInputFilter
{
    GLint widthOffsetUniform;
    CGFloat widthOffset;
    
    GLint heightOffsetUniform;
    CGFloat heightOffset;
    
    NSInteger iWidth;
    NSInteger iHeight;
    
    //CGFloat mixturePercent;
    NSInteger mixturePercentUniform;
    
}

-(id)initMixturePercent:(CGFloat) mixturePercent;
@end
