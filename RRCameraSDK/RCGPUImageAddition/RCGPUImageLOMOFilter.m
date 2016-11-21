//
//  RCGPUImageLOMOFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/1/16.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageLOMOFilter.h"

@implementation RCGPUImageLOMOFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //Normal Image
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"LOMOOverlayMap" ofType:@"png"]];
    NSAssert(image,@"To use RCGPUImageLOMOFilter you need to add LOMOOverlayMap to your application bundle.");
    ImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageNormalBlendFilter *ImageFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addFilter:ImageFilter];
    [ImageSource addTarget:ImageFilter atTextureLocation:1];
    [ImageSource processImage];
    
    //Curve
    GPUImageToneCurveFilter *curve = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"LOMO_color_curve" withExtension:@"acv"]];
    [self addFilter:curve];
    [ImageFilter addTarget:curve];
    
    self.initialFilters = [NSArray arrayWithObjects:ImageFilter,nil];
    self.terminalFilter = curve;
    
    return self;
}

@end