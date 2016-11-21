//
//  RCGPUImageDermabrasionSimpleFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/8/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface RCGPUImageDermabrasionSimpleFilter : GPUImageTwoInputFilter
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
//- (void) setFaceRect:(CGRect)faceRect;
- (void) setGray:(CGFloat)faceGray;
@end
