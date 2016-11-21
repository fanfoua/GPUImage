//
//  RCGPUImageFourInputFilter.h
//  RRCameraSDK
//
//  Created by ran.shi on 14-7-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageThreeInputFilter.h"

@interface RCGPUImageFourInputFilter : RCGPUImageThreeInputFilter
{
    GPUImageFramebuffer *fourthInputFramebuffer;
    
    GLint filterFourthTextureCoordinateAttribute;
    GLint filterInputTextureUniform4;
    GPUImageRotationMode inputRotation4;
    GLuint filterSourceTexture4;
    CMTime fourthFrameTime;
    
    BOOL hasSetThirdTexture, hasReceivedFourthFrame, fourthFrameWasVideo;
    BOOL fourthFrameCheckDisabled;
}

- (void)disableFourthFrameCheck;

@end
