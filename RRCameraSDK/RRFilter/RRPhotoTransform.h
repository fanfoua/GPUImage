//
//  RRPhotoTransform.h
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.

/**
 *   功能说明:
 *   完成照片分解RGB值，及处理后合成照片。
 **/
#import <UIKit/UIKit.h>

CGContextRef createCMYKBitmapContext(CGImageRef inImage);
 
unsigned char *RequestImageCMYKPixelData(UIImage *inImage);

UIImage *initImageWithCMYKPixel(void *Inpixel,uint width,uint height);
UIImage *initImageWithPixelNoReleaseInpixel(void *Inpixel,uint width,uint height);

CGContextRef createRGBBitmapContext(CGImageRef inImage);

/**
 * @brief 图像数据转换为 uchar RGB像素值
 * @param inImage  图片源数据
 * @return RGB像素值
 */
unsigned char *RequestImagePixelsData(UIImage *inImage);

/**
 * @brief uchar RGB值 转换为 图像数据 
 * @param Inpixel RGB像素值
 * @param width  图像宽度
 * @param height 图像高度
 * @return  图像数据
 */
UIImage * initImageWithPixel(void *Inpixel,uint width,uint height);
