//
//  RCGPUImageCityLightFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14/11/15.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RCGPUImageCityLightFilter.h"
#import "Modules/RCGPUImageMapFilter.h"

@implementation RCGPUImageCityLightFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
        
//    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[resBundle
//                                                                pathForResource:@"CityLight_color_map33" ofType:@"png"]];
    
    UIImage *image = [UIImage imageWithData:[RCDecrypt dealDecrypt:
                                              [resBundle URLForResource:@"CityLight_color_map33" withExtension:@"png"]]];
//
    NSAssert(image,
                 @"To use RCGPUImageInsCremaFilter you need to add CityLight_color_map33.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image];
    RCGPUImageMapFilter *MapFilter = [[RCGPUImageMapFilter alloc] init];
    [self addFilter:MapFilter];
    [ImageSource1 addTarget:MapFilter atTextureLocation:1];
    [ImageSource1 processImage];
        
    self.initialFilters = [NSArray arrayWithObjects:MapFilter,nil];
    self.terminalFilter = MapFilter;
    
    return self;
}

@end