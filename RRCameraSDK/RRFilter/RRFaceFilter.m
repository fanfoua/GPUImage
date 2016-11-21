//
//  FaceFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 14-7-21.
//  Copyright (c) 2014年 renn. All rights reserved.
//

#import "RRFaceFilter.h"
#import "RRPhotoFilter.h"
#import "RRPhotoTransform.h"

@implementation RRFaceFilter

//等比缩放
+ (UIImage *) scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    CGFloat width = floorf(image.size.width * scaleSize);
    CGFloat height = floorf(image.size.height * scaleSize);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width*scaleSize, height*scaleSize), NO, [[UIScreen mainScreen] scale]);
    [image drawInRect:CGRectMake(0, 0, width*scaleSize, height*scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage *) photoSmoothAndWhitenFilter:(UIImage *) srcImage andMax:(NSInteger) maxLen
{
    if (!srcImage) {
        return nil;
    }
    
    double time = [NSDate timeIntervalSinceReferenceDate];
    UIImage *image = srcImage;
//    UIImage *image = [RRFaceFilter scaleImage:srcImage toScale:1];
    
    CGImageRef inImageRef = [image CGImage];
    uint width = CGImageGetWidth(inImageRef);
    uint height = CGImageGetHeight(inImageRef);
    
    // 获取图片像素
    unsigned char *buttomPixel = RequestImagePixelsData(image);
    unsigned char *topPixel = RequestImagePixelsData(image);
    
    // 底图操作
    ImageWhitenFilter(buttomPixel, width, height, 1);
    
    // 顶图操作
    ImageWhitenFilterTest(topPixel, width, height, 1);
    
    NSLog(@"God, ImageWhiten time is %f",[NSDate timeIntervalSinceReferenceDate] - time);

    time = [NSDate timeIntervalSinceReferenceDate];
    domain_fuck_bilateral_filter(topPixel, width, height, 0.03,0.08);
    NSLog(@"God, bilateral time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
    
    UIImage * bottomImage = initImageWithPixel(buttomPixel, width, height);
    UIImage * topImage = initImageWithPixel(topPixel, width, height);
    
    CGRect rect = CGRectMake(0, 0,width, height);
    CGSize size = CGSizeMake(width, height);
    
    UIGraphicsBeginImageContext(size);
    
    // 合成
    [bottomImage drawInRect:rect];
    [topImage drawInRect:rect blendMode:kCGBlendModeNormal  alpha:0.6];
    
    // 生成最终图片
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();

//    [ALAssetsLibrary saveImage:resultingImage metadata:nil completionBlock:nil];
//    unsigned char *midPixel = RequestImagePixelsData(resultingImage);
//    
//    time = [NSDate timeIntervalSinceReferenceDate];
//    ImageContrastFilterTest(midPixel, width, height,1); // 优化对比度
//    NSLog(@"God, Contrast time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
//    resultingImage = initImageWithPixel(midPixel, width, height);
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}

@end
