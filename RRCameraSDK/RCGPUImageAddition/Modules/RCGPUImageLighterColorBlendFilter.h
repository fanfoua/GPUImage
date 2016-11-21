//
//  RCGPUImageLightColorBlendFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-15.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"
@interface RCGPUImageLighterColorBlendFilter : GPUImageTwoInputFilter
{
    GLint mixUniform;
}

- (id)initMixturePercent: (CGFloat)mixturePercent;

@property(readwrite, nonatomic) CGFloat mix;

@end
