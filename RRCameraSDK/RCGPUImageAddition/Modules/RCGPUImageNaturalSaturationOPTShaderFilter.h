//
//  RCGPUImageNaturalSaturationOPTFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-3-5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageNaturalSaturationOPTShaderFilter : GPUImageTwoInputFilter
{
    GLint s_low_boundUniform;
    GLint s_up_boundUniform;
    GLint s_refineUniform;
    
}

// vibrance ranges from -100 to 100, with 0.0 as the normal level
- (id)initIratio:(int)iratio;
@end