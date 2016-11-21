//
//  RCGPUImageLuxFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/26.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageLuxFilter.h"
#import "RCIGBoxBlurFilter.h"
#import "RCIGCdfFilter.h"
#import "RCIGAntiLuxFilter.h"
#import "RCIGStarlightFilter.h"
#import "RCIGLuxBlendFilter.h"

@implementation RCGPUImageLuxFilter

- (id)initWithPara:(UIImage *)image luxBlendAmount:(float)luxBlendAmount
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    CGImageRef inImageRef = [image CGImage];
    uint height = CGImageGetWidth(inImageRef);
    
    UIImage *cdf = [RCIGCdfFilter RCIGCdfFilter:image];
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:cdf];
    
    RCIGStarlightFilter *StarlightFilter = [[RCIGStarlightFilter alloc] init];
    [self addFilter:StarlightFilter];
    [ImageSource1 addTarget:StarlightFilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    RCIGBoxBlurFilter *BoxBlurFilter = [[RCIGBoxBlurFilter alloc] init];
    [(RCIGBoxBlurFilter *)BoxBlurFilter setBlurVector:CGPointMake(0,1.0 / height)];
    [self addFilter:BoxBlurFilter];
    
    RCIGAntiLuxFilter *AntiLuxFilter = [[RCIGAntiLuxFilter alloc] init];
    [self addFilter:AntiLuxFilter];
    [ImageSource1 addTarget:AntiLuxFilter atTextureLocation:1];
    [BoxBlurFilter addTarget:AntiLuxFilter atTextureLocation:2];
    [ImageSource1 processImage];

    RCIGLuxBlendFilter *LuxBlendFilter = [[RCIGLuxBlendFilter alloc] init];
    [(RCIGLuxBlendFilter *)LuxBlendFilter setLuxBlendAmount:luxBlendAmount];
    [self addFilter:LuxBlendFilter];
    [StarlightFilter addTarget:LuxBlendFilter atTextureLocation:1];
    [AntiLuxFilter addTarget:LuxBlendFilter atTextureLocation:2];

    self.initialFilters = [NSArray arrayWithObjects:StarlightFilter,BoxBlurFilter,AntiLuxFilter,LuxBlendFilter,nil];
    self.terminalFilter = LuxBlendFilter;
    
    return self;
}
@end