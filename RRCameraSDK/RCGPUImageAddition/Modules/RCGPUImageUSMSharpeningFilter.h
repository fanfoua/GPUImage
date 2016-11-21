//
//  RCGPUImageUSMSharpeningFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-1-19.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"
#import "RCGPUImageGaussianBlurPassParamFilter.h"

@interface RCGPUImageUSMSharpeningFilter : GPUImageFilterGroup
{
    RCGPUImageGaussianBlurPassParamFilter *blurFilter;
    GPUImageFilter *sharpeningFilter;
}

@property (readwrite, nonatomic) CGFloat iThreshold;
@property (readwrite, nonatomic) CGFloat fProportion;

- (id)initCount:(CGFloat)fProportion initRadius:(NSUInteger)iRadius initThreshold:(NSUInteger)iThreshold;
@end