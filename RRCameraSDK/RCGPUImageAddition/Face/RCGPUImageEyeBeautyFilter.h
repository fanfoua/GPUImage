//
//  RCGPUImageEyeBeautyFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/6/5.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"
#import "RCGPUImageGaussianBlurPassParamFilter.h"

@interface RCGPUImageEyeBeautyFilter : GPUImageFilterGroup
{
    RCGPUImageGaussianBlurPassParamFilter *blurFilter;
    GPUImageFilter *sharpeningFilter;
}

@property (readwrite, nonatomic) CGFloat iThreshold;
@property (readwrite, nonatomic) CGFloat fProportion;

- (id)initFaceRect:(struct FACERECT*)faceRect initImageSize:(CGSize)size initCount:(CGFloat)fProportion initRadius:(NSUInteger)iRadius initThreshold:(NSUInteger)iThreshold;
@end
