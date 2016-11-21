//
//  RRSceneryFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-8-8.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RRBrightnessAndSaturationFilter.h"
#import "RRSceneryFilter.h"
#import "RRPhotoTransform.h"

@implementation RRSceneryFilter


+ (UIImage *) photoBrightnessAndSaturationFilter:(UIImage *) srcImage andMax:(NSInteger) maxLen
{
    if (!srcImage) {
        return nil;
    }
    
    double time = [NSDate timeIntervalSinceReferenceDate];
    
    //  UIImage * image = [self scaleAndRotateImage:srcImage andMax: maxLen];
    UIImage *image = srcImage;
    int width = image.size.width;
    int height = image.size.height;
    
    // 获取图片像素
    unsigned char *imgPixel = RequestImagePixelsData(image);
    
    int r = BrightnessAndSaturation(imgPixel, height, width, 4);
    
    if (r != 0) {
        NSLog(@"BrightnessAndSaturation error!");
    }
    
    NSLog(@"God, RRSceneryFilter time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
    
    UIImage *resultingImage = initImageWithPixel(imgPixel, width, height);
    
    return resultingImage;
}

@end