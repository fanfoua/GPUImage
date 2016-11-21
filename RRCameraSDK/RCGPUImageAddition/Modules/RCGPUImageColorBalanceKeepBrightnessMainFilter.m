//
//  RCGPUImageColorBalanceKeepBrightnessMainFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/7/3.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageColorBalanceKeepBrightnessMainFilter.h"
#import "RCGPUImageColorBalanceKeepBrightnessFilter.h"

@implementation RCGPUImageColorBalanceKeepBrightnessMainFilter
- (id)initShadowShiftR:(NSInteger) shadowShiftR shadowShiftG:(NSInteger) shadowShiftG  shadowShiftB: (NSInteger) shadowShiftB midShiftR: (NSInteger) midShiftR midShiftG:(NSInteger) midShiftG midShiftB:(NSInteger) midShiftB highlightShiftR:(NSInteger) highlightShiftR highlightShiftG:(NSInteger) highlightShiftG highlightShiftB:(NSInteger) highlightShiftB;
{
    NSBundle *resBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle]
                                                    pathForResource:@"RRCameraRes" ofType:@"bundle"]];
    
    RCGPUImageColorBalanceKeepBrightnessFilter *ColorBalanceKeepBrightnessFilter = [[RCGPUImageColorBalanceKeepBrightnessFilter alloc] initShadowShiftR:shadowShiftR shadowShiftG:shadowShiftG shadowShiftB:shadowShiftB midShiftR:midShiftR midShiftG:midShiftG midShiftB:midShiftB highlightShiftR:highlightShiftR highlightShiftG:highlightShiftG highlightShiftB:highlightShiftB];
    
    UIImage *image1 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"ColorBalanceKeepBrightness1" ofType:@"png"]];
    
    //    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
    //                                              [resBundle URLForResource:@"willowMap" withExtension:@"png"]]];
    
    ImageSource1 = [[GPUImagePicture alloc] initWithImage:image1];
    
    [ImageSource1 addTarget:ColorBalanceKeepBrightnessFilter atTextureLocation:1];
    
    [ImageSource1 processImage];
    
    
    UIImage *image2 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"ColorBalanceKeepBrightness2" ofType:@"png"]];
    
    //    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
    //                                              [resBundle URLForResource:@"willowMap" withExtension:@"png"]]];
    
    ImageSource2 = [[GPUImagePicture alloc] initWithImage:image2];
    
    [ImageSource2 addTarget:ColorBalanceKeepBrightnessFilter atTextureLocation:2];
    
    [ImageSource2 processImage];
    
    
    UIImage *image3 = [[UIImage alloc] initWithContentsOfFile:[resBundle
                                                               pathForResource:@"ColorBalanceKeepBrightness3" ofType:@"png"]];
    
    //    UIImage *image1 = [UIImage imageWithData:[RCDecrypt dealDecrypt:
    //                                              [resBundle URLForResource:@"willowMap" withExtension:@"png"]]];
    
    ImageSource3 = [[GPUImagePicture alloc] initWithImage:image3];
    
    [ImageSource3 addTarget:ColorBalanceKeepBrightnessFilter atTextureLocation:3];
    
    [ImageSource3 processImage];
    
    self.initialFilters = [NSArray arrayWithObjects:ColorBalanceKeepBrightnessFilter, nil];
    self.terminalFilter = ColorBalanceKeepBrightnessFilter;
    return self;
}
@end
