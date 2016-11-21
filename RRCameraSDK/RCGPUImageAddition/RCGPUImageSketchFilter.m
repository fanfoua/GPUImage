//
//  RCGPUImageSketchFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/31.
//  Copyright (c) 2015年 renn. All rights reserved.
//
//官客 素描
#import "RCGPUImageSketchFilter.h"
#import "RCGPUImageCartoonFilter.h"

@implementation RCGPUImageSketchFilter

-(id)init;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    RCGPUImageCartoonFilter *toonFilter1  = [[RCGPUImageCartoonFilter alloc] initThreshold:1.0 Amounts:15.0];
    self.initialFilters = [NSArray arrayWithObjects:toonFilter1, nil];
    self.terminalFilter = toonFilter1;
    return self;
}
@end
