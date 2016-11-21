//
//  RCIGAntiLuxFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/22.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageThreeInputFilter.h"

@interface RCIGAntiLuxFilter : RCGPUImageThreeInputFilter
{
    GLint filterStrengthUniform;
}

@property(readwrite, nonatomic) CGFloat filterStrength;
@end