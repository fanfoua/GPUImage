//
//  RCGPUImageInsLudwidFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageInsLudwidFilter.h"
#import "Modules/RCGPUImageMapFilter.h"
#import "Modules/RCGPUImageYMapFilter.h"

@implementation RCGPUImageInsLudwidFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_ludwig_map" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_ludwig_map" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageInsLudwidFilter you need to add ins_ludwig_map.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    RCGPUImageMapFilter *MapFilter = [[RCGPUImageMapFilter alloc] init];
    [self addFilter:MapFilter];
    [ImageSource1 addTarget:MapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    

//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_vignette_map" ofType:@"png"]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_vignette_map" withExtension:@"png"]]];
    NSAssert(image2, @"To use RCGPUImageInsSlumberFilter you need to add ins_vignette_map.png to your application bundle.");
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    RCGPUImageYMapFilter *YMapFilter =[[RCGPUImageYMapFilter alloc] init];
    [self addFilter:YMapFilter];
    
    [MapFilter addTarget:YMapFilter atTextureLocation:0];
    [ImageSource2 addTarget:YMapFilter atTextureLocation:1];
    
    [ImageSource2 processImage];
    
    
    self.initialFilters = [NSArray arrayWithObjects:MapFilter,nil];
    self.terminalFilter = YMapFilter;
    
    return self;
}
@end
