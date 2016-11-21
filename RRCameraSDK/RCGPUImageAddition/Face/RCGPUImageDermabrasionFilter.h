//
//  RCGPUImageDermabrasionFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/17.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageThreeInputFilter.h"

extern float paraArray[256];

@interface RCGPUImageDermabrasionFilter : GPUImageThreeInputFilter
{
    GLint surfaceblurWidthOffsetUniform;
    GLint surfaceblurHeightOffsetUniform;
    GLfloat surfaceblurWidthOffset;
    GLfloat surfaceblurHeightOffset;
    GLint glstepforsurfaceblur;
    GLint texeThresholdUniform;
    GLfloat fThreshold;
    float fStep;
    int iRadius;
    
}
- (id)initRadius:(int)radius initThreshold:(GLfloat)thr;

@end
