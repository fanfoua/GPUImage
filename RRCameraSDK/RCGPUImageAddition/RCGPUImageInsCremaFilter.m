//
//  RCGPUImageInsCremaFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15-4-11.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageInsCremaFilter.h"
#import "Modules/RCGPUImageMapFilter.h"

@implementation RCGPUImageInsCremaFilter

- (id)init
{
    if (!(self = [super init]))
    {
        return nil;
    }
    
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
//    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle pathForResource:@"ins_crema_map" ofType:@"png"]];
    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:[resBundle URLForResource:@"ins_crema_map" withExtension:@"png"]]];
    NSAssert(image1, @"To use RCGPUImageInsCremaFilter you need to add ins_crema_map.png to your application bundle.");
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    RCGPUImageMapFilter *MapFilter = [[RCGPUImageMapFilter alloc] init];
    [self addFilter:MapFilter];
    [ImageSource1 addTarget:MapFilter atTextureLocation:1];
    [ImageSource1 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:MapFilter,nil];
    self.terminalFilter = MapFilter;
    
    return self;
}

@end