//
//  RCGPUImageAutoContrastFilter.h
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/29.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageAutoContrastFilter : GPUImageFilter
{
    GLint histUniform;
}
- (id)initImg:(unsigned char *)img initW:(int)w initH:(int)h initThr:(float)thr;
@end
