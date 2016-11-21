//
//  RCGPUImageTotalRotateFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/5/11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageTotalRotateFilter.h"
#import "RCGPUImageRotate90Filter.h"
#import "RCGPUImage2DRotateFilter.h"
#import "RCGPUImage3DRotationFilter.h"

@implementation RCGPUImageTotalRotateFilter

- (id)initPara:(int)flag theta:(float)theta;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    //2D ratation
    if (flag == 0) {
        RCGPUImage2DRotateFilter *_2DRotateFilter = [[RCGPUImage2DRotateFilter alloc] init];
        [(RCGPUImage2DRotateFilter *)_2DRotateFilter setTheta:theta/50.0];
        [self addFilter:_2DRotateFilter];
        
        self.initialFilters = [NSArray arrayWithObjects:_2DRotateFilter, nil];
        self.terminalFilter = _2DRotateFilter;
    }
    //3DRotation, left button
    else if(flag == -1)
    {
        RCGPUImageRotate90Filter *RotateFilter1 = [[RCGPUImageRotate90Filter alloc] init];
        [(RCGPUImageRotate90Filter *)RotateFilter1 setFlag:-1];
        [self addFilter:RotateFilter1];
        
        //theta [-25, 25], delta[1.2,0.8]
        RCGPUImage3DRotationFilter *_3DRotationFilter = [[RCGPUImage3DRotationFilter alloc]
                                                         initPara:flag theta:(1.0+(-theta/125.0))];
        [self addFilter:_3DRotationFilter];
        [RotateFilter1 addTarget:_3DRotationFilter];
        
        RCGPUImageRotate90Filter *RotateFilter2 = [[RCGPUImageRotate90Filter alloc] init];
        [(RCGPUImageRotate90Filter *)RotateFilter2 setFlag:1];
        [self addFilter:RotateFilter2];
        [_3DRotationFilter addTarget:RotateFilter2];
        
        self.initialFilters = [NSArray arrayWithObjects:RotateFilter1, nil];
        self.terminalFilter = RotateFilter2;
    }
    //3DRotation, right button
    else if (flag == 1)
    {
        //theta [-25, 25], delta[1.2,0.8]
        RCGPUImage3DRotationFilter *_3DRotationFilter = [[RCGPUImage3DRotationFilter alloc]
                                                         initPara:flag theta:(1.0+(-theta/125.0))];
        [self addFilter:_3DRotationFilter];
        
        self.initialFilters = [NSArray arrayWithObjects:_3DRotationFilter, nil];
        self.terminalFilter = _3DRotationFilter;
    }
    
    return self;
}

@end