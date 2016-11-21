//
//  RCGPUImageInsPerpetuaFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageInsPerpetuaFilter.h"
#import "Modules/RCGPUImageMapFilter.h"
#import "Modules/RCGPUImageLineMapFilter.h"

@implementation RCGPUImageInsPerpetuaFilter
- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    //
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_perpetua_map" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_perpetua_map" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageInsPerpetuaFilter you need to add ins_slumber_map.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    RCGPUImageMapFilter *MapFilter = [[RCGPUImageMapFilter alloc] init];
    [self addFilter:MapFilter];
    [ImageSource1 addTarget:MapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    

//    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_perpetua_overlay_map" ofType:@"png"]];
    UIImage *image2 = [UIImage imageWithData:[RCDecrypt dealDecrypt: [resBundle URLForResource:@"ins_perpetua_overlay_map" withExtension:@"png"]]];
    NSAssert(image2, @"To use RCGPUImageInsPerpetuaFilter you need to add ins_perpetua_overlay_map.png to your application bundle.");
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
//    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_vignette_map" ofType:@"png"]];
    UIImage *image3 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_vignette_map" withExtension:@"png"]]];
    NSAssert(image3, @"To use RCGPUImageInsPerpetuaFilter you need to add ins_vignette_map.png to your application bundle.");
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    
    RCGPUImageLineMapFilter *LineMapFilter =[[RCGPUImageLineMapFilter alloc] init];
    [self addFilter:LineMapFilter];
    
    [MapFilter addTarget:LineMapFilter atTextureLocation:0];
    [ImageSource2 addTarget:LineMapFilter atTextureLocation:1];
    [ImageSource3 addTarget:LineMapFilter atTextureLocation:2];
    
    [ImageSource2 processImage];
    [ImageSource3 processImage];

    
    self.initialFilters = [NSArray arrayWithObjects:MapFilter,nil];
    self.terminalFilter = LineMapFilter;
 
    return self;
}
@end
