//
//  RCGPUImageCartoonFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/6.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageCartoonFilter : GPUImageFilter
{
    GLint widthOffsetUniform;
    CGFloat widthOffset;
    
    GLint heightOffsetUniform;
    CGFloat heightOffset;
    
    GLint thresholdUniform;
    //CGFloat threshold;
    
    GLint amountsUniform;
    //CGFloat amounts;
    
//    NSInteger iWidth;
//    NSInteger iHeight;
}
-(id)initThreshold:(CGFloat)threshold Amounts:(CGFloat)amounts;
@end
