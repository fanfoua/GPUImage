//
//  RCGPUImageFiveInputFilter.h
//  RRCameraSDK
//
//  Created by ran.shi on 14-7-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageFourInputFilter.h"

@interface RCGPUImageFiveInputFilter : RCGPUImageFourInputFilter
{
    GPUImageFramebuffer *fifthInputFramebuffer;
    
    GLint filterFifthTextureCoordinateAttribute;
    GLint filterInputTextureUniform5;
    GPUImageRotationMode inputRotation5;
    GLuint filterSourceTexture5;
    CMTime fifthFrameTime;
    
    BOOL hasSetFourthTexture, hasReceivedFifthFrame, fifthFrameWasVideo;
    BOOL fifthFrameCheckDisabled;
}

- (void)disableFifthFrameCheck;

@end
