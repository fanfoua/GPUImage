//
//  RCGPUImageThreeInputFilter.m
//  RRCameraSDK
//
//  Created by ran.shi on 14-7-20.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageThreeInputFilter.h"

@implementation RCGPUImageThreeInputFilter

- (void)setInputFramebuffer:(GPUImageFramebuffer *)newInputFramebuffer atIndex:(NSInteger)textureIndex;
{
    if (textureIndex == 0)
    {
        firstInputFramebuffer = newInputFramebuffer;
        hasSetFirstTexture = YES;
        [firstInputFramebuffer lock];
    }
    else if (textureIndex == 1)
    {
        secondInputFramebuffer = newInputFramebuffer;
        hasSetSecondTexture = YES;
        [secondInputFramebuffer lock];
    }
    else
    {
        thirdInputFramebuffer = newInputFramebuffer;
        [thirdInputFramebuffer lock];
    }
}

@end
