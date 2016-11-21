//
//  RCGPUImageNaturalSaturationOPTMainFilter.m
//  RenrenOfficial-iOS-Concept
//
//  Created by 0153-00503 on 15/10/19.
//  Copyright © 2015年 renren. All rights reserved.
//

#import "RCGPUImageNaturalSaturationOPTFilter.h"
#import "RCGPUImageNaturalSaturationOPTShaderFilter.h"

@implementation RCGPUImageNaturalSaturationOPTFilter
- (id)initIratio:(int)iratio
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];

    //NaturalSaturation: +35
    RCGPUImageNaturalSaturationOPTShaderFilter *NaturalSaturationOPTFilter = [[RCGPUImageNaturalSaturationOPTShaderFilter alloc] initIratio:iratio];
    [self addFilter:NaturalSaturationOPTFilter];
    
    UIImage *paraImg = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                                pathForResource:@"NaturalSaturationOPT1" ofType:@"png"]];
    NSAssert(paraImg,
             @"To use RCGPUImageNaturalSaturationOPTFilter you need to add NaturalSaturationOPT1.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:paraImg];//生成图像资源
    [ImageSource1 addTarget:NaturalSaturationOPTFilter atTextureLocation:1];//把图像资源导入到调用的filter中
    [ImageSource1 processImage];
    
    
    self.initialFilters = [NSArray arrayWithObjects:NaturalSaturationOPTFilter,nil];
    self.terminalFilter = NaturalSaturationOPTFilter;
    
    return self;
}

@end
