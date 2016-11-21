//
//  RCGPUImageWatermarkFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/3/13.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageWatermarkFilter.h"
#import "Modules/RCGPUImageSourceImageFilter.h"

@implementation RCGPUImageWatermarkFilter

- (id) initWithPara:(CGFloat)blurRadiusInPixels image:(UIImage *)image;
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    if (blurRadiusInPixels == 0) {
        RCGPUImageSourceImageFilter *SourceImageFilter = [[RCGPUImageSourceImageFilter alloc] init];
        [self addFilter:SourceImageFilter];
        
        self.initialFilters = [NSArray arrayWithObjects:SourceImageFilter, nil];
        self.terminalFilter = SourceImageFilter;
        
    }
    else {
        //Gaussian blur (0，1】 - (0，24】
        GPUImageGaussianBlurFilter *GaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
        GaussianBlurFilter.blurRadiusInPixels = 24*blurRadiusInPixels;
        [self addFilter:GaussianBlurFilter];
        
        if (image == nil) {
            self.initialFilters = [NSArray arrayWithObjects:GaussianBlurFilter, nil];
            self.terminalFilter = GaussianBlurFilter;
        }
        else
        {
            ImageSource1 = [[GPUImagePicture alloc] initWithImage:image];
            GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
            [self addFilter:NormalBlendFilter];
            [ImageSource1 addTarget:NormalBlendFilter atTextureLocation:1];
            [ImageSource1 processImage];
            [GaussianBlurFilter addTarget:NormalBlendFilter];
            
            self.initialFilters = [NSArray arrayWithObjects:GaussianBlurFilter, nil];
            self.terminalFilter = NormalBlendFilter;
        }
    }
    
    return self;
}

@end