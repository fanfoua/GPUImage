//
//  RCGPUImageTotalRotateFilter.h
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "GPUImageFilterGroup.h"

@interface RCGPUImageTotalRotateFilter : GPUImageFilterGroup

//flag:-1:left 3D, 0:2D , 1:right 3D
//theta [-25, 25],
- (id)initPara:(int)flag theta:(float)theta;

@end