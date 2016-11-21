//
//  RCGPUImageFaceBeautifyFilter.m
//  RRCameraSDK
//
//  Created by 0153-00503 on 15/4/21.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCGPUImageFaceBeautifyFilter.h"
#import "RCGPUImageFaceDermabrasionFilter.h"
#import "RCGPUImageBrightnessFilter.h"
#import "RCGPUImageFaceInitFilter.h"
#import "RCFaceHistStatisticsFilter.h"
@implementation RCGPUImageFaceBeautifyFilter


- (id)initImg:(UIImage *)image
{
    if (!(self = [super init]))
    {
        return nil;
    }

    int graythr,faceWidth,grayAve;
    struct FACERECT faceRect;
    RCGPUImageFaceInitFilter * FaceInitFilter=[[RCGPUImageFaceInitFilter alloc] initImg:image Graythr:&graythr FaceWidth:&faceWidth GrayAve:&grayAve FaceRect:&faceRect FaceParameter:NULL];

    RCGPUImageFaceDermabrasionFilter * FaceDermabrasionFilter=[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image Graythr:graythr FaceWidth:faceWidth];

//    RCGPUImageFaceDermabrasionFilter * FaceDermabrasionFilter=[[RCGPUImageFaceDermabrasionFilter alloc] initImg:image initGrayAve:&grayave];
    
    CGFloat bright=50;
    if (grayAve>185)
    {
        bright=35;
    }
    
    //Brightness:10
    RCGPUImageBrightnessFilter *BrightnessFilter = [[RCGPUImageBrightnessFilter alloc] init];
    [(RCGPUImageBrightnessFilter *)BrightnessFilter setBrightness:bright];
    [self addFilter:BrightnessFilter];
    [FaceDermabrasionFilter addTarget:BrightnessFilter atTextureLocation:0];
    
//    //Opacity透明度
//    GPUImageOpacityFilter *OpacityFilter = [[GPUImageOpacityFilter alloc] init];
//    [(GPUImageOpacityFilter *)OpacityFilter setOpacity:(0.8f)];
//    [self addFilter:OpacityFilter];
//    [BrightnessFilter addTarget:OpacityFilter];
//    
//    //NormalBlendFilter
//    GPUImageNormalBlendFilter *NormalBlendFilter = [[GPUImageNormalBlendFilter alloc] init];
//    //[self addTarget:NormalBlendFilter];
//    //[autoContrast addTarget:NormalBlendFilter atTextureLocation:0];
//    [OpacityFilter addTarget:NormalBlendFilter atTextureLocation:1];

    

    self.initialFilters = [NSArray arrayWithObjects:FaceDermabrasionFilter,nil];
    self.terminalFilter = BrightnessFilter;

    return self;
}

@end
