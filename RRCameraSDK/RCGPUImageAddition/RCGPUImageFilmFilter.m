//
//  RCGPUImageFilmFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/1/16.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageFilmFilter.h"

@implementation RCGPUImageFilmFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    //Curve
    GPUImageToneCurveFilter *curve = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"Film_color_curve" withExtension:@"acv"]];
    [self addFilter:curve];
    
    //Normal Image
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"FilmOverlayMap" ofType:@"png"]];
    NSAssert(image,@"To use RCGPUImageFilmFilter you need to add FilmOverlayMap.png to your application bundle.");
    ImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageNormalBlendFilter *ImageFilter = [[GPUImageNormalBlendFilter alloc] init];
    [self addFilter:ImageFilter];
    [ImageSource addTarget:ImageFilter atTextureLocation:1];
    [ImageSource processImage];
    [curve addTarget:ImageFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:curve,nil];
    self.terminalFilter = ImageFilter;
    
    return self;
}

@end