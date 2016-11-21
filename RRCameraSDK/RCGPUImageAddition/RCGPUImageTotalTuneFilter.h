//
//  RCGPUImageTotalTuneFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/1/9.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilter.h"
#import "RCGPUImageInsFineTuneFilter.h"

@interface RCGPUImageTotalTuneFilter : GPUImageFilterGroup

//- (id)initWithParameters:(float)lux
//              brightness:(float)brightness contrast:(float)contrast saturation:(float)saturation
//             temperature:(float)temperature highlight:(float)highlight shadow:(float)shadow
//               sharpness:(float)sharpness vignetteEnd:(float)vignetteEnd
//            isLinearOpen:(bool)isLinearOpen linearCenter:(float)linearCenter linearRadius:(float)linearRadius
//            isRadialOpen:(bool)isRadialOpen radialCenterX:(float)radialCenterX radialCenterY:(float)radialCenterY radialRadius:(float)radialRadius image:(UIImage *)image;
- (id)initWithParameters:(InsFineTune*)insFineTune image:(UIImage*)image;
@end