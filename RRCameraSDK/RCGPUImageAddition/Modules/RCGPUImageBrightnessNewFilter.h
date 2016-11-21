//
//  RCGPUImageBrightnessNewFilter.h
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 16/4/26.
//  Copyright © 2016年 renren. All rights reserved.
//

#import "GPUImageFilter.h"

@interface RCGPUImageBrightnessNewFilter : GPUImageFilter
{
    GLint brightnessUniform;
}

// Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
@property(readwrite, nonatomic) CGFloat brightness;
@end
