//
//  RCGPUImageOldDaysFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/1/18.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageOldDaysFilter.h"
#import "Modules/RCGPUImageNaturalSaturationFilter.h"
#import "Modules/RCGPUImageLighterColorBlendFilter.h"

@implementation RCGPUImageOldDaysFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];

    //Curve
    GPUImageToneCurveFilter *curve = [[GPUImageToneCurveFilter alloc] initWithACVURL:[resBundle URLForResource:@"OldDays_color_curve" withExtension:@"acv"]];
    [self addFilter:curve];
    
    //Normal Image
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"OldDaysOverlayMap" ofType:@"png"]];
    NSAssert(image,@"To use RCGPUImageOldDaysFilter you need to add OldDaysOverlayMap.png to your application bundle.");
    ImageSource = [[GPUImagePicture alloc] initWithImage:image];
    RCGPUImageLighterColorBlendFilter *ImageFilter = [[RCGPUImageLighterColorBlendFilter alloc] init];
    [self addFilter:ImageFilter];
    [ImageSource addTarget:ImageFilter atTextureLocation:1];
    [ImageSource processImage];
    [curve addTarget:ImageFilter];
    
    self.initialFilters = [NSArray arrayWithObjects:curve,nil];
    self.terminalFilter = ImageFilter;
    
    return self;
}

@end
