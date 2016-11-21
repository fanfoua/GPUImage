//
//  RRPhotoTransform.m
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//

#import "RRPhotoTransform.h"

CGContextRef createCMYKBitmapContext(CGImageRef inImage)
{
    CGContextRef context=NULL;
    CGColorSpaceRef  colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide=CGImageGetWidth(inImage);
    size_t pixelsHeight=CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (pixelsWide *5);
    bitmapByteCount = bitmapBytesPerRow*pixelsHeight;
    
    // colorSpace= CGColorSpaceCreateDeviceRGB();
    colorSpace=CGColorSpaceCreateDeviceCMYK();
    bitmapData=malloc(bitmapByteCount);
    
    context=CGBitmapContextCreate(bitmapData,
                                  pixelsWide,
                                  pixelsHeight,
                                  8,
                                  bitmapBytesPerRow,
                                  colorSpace,
                                  kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    
    CGColorSpaceRelease(colorSpace);
    return  context;
    
}

unsigned char *RequestImageCMYKPixelData(UIImage *inImage)
{
    
    if (!inImage) {
        return NULL;
    }
    
    CGImageRef img=[inImage CGImage];
    CGSize size=[inImage size];
    
    // CGContextRef cgctx=createRGBBitmapContext(img);
    CGContextRef cgctx=createCMYKBitmapContext(img);
    
    CGRect rect={{0,0},{size.width,size.height}};
    
    CGContextDrawImage(cgctx, rect, img);
    unsigned char *data=( unsigned char *)CGBitmapContextGetData(cgctx);
    
    CGContextRelease(cgctx);
    return data;
}


UIImage * initImageWithCMYKPixel(void *Inpixel,uint width,uint height)
{
    if (Inpixel == NULL) {
        return  nil;
    }
    
    void *imgPixel = Inpixel;
    uint w = width, h = height;
    
    uint dataLength=w*h*5;
    CGDataProviderRef provider=CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    
    int bitsPerComponent=8;
    int bitsPerPixel=40;
    int bytesPerRow=5*w;
    CGColorSpaceRef colorSpaceRef=CGColorSpaceCreateDeviceCMYK();
    CGBitmapInfo bitmapInfo=kCGBitmapByteOrderDefault;
    
    CGColorRenderingIntent renderingIntent=kCGRenderingIntentDefault;
    
    CGImageRef imageRef=CGImageCreate(w, h,
                                      bitsPerComponent,
                                      bitsPerPixel,
                                      bytesPerRow,
                                      colorSpaceRef,
                                      bitmapInfo,
                                      provider, NULL, NO, renderingIntent);
    
    
    UIImage *my_Image=[UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return my_Image;
}


CGContextRef createRGBBitmapContext(CGImageRef inImage)
{
    CGContextRef context=NULL;
    CGColorSpaceRef  colorSpace;
    void *bitmapData;
    int bitmapByteCount;
    int bitmapBytesPerRow;
    
    size_t pixelsWide=CGImageGetWidth(inImage);
    size_t pixelsHeight=CGImageGetHeight(inImage);
    
    bitmapBytesPerRow = (pixelsWide *4);
    bitmapByteCount = bitmapBytesPerRow*pixelsHeight;
    
    colorSpace= CGColorSpaceCreateDeviceRGB();
    bitmapData=malloc(bitmapByteCount);
    
    context=CGBitmapContextCreate(bitmapData,
                                  pixelsWide,
                                  pixelsHeight,
                                  8,
                                  bitmapBytesPerRow,
                                  colorSpace,
                                  kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    
    CGColorSpaceRelease(colorSpace);
//    free(bitmapData);
    return  context;
    
}

unsigned char *RequestImagePixelsData(UIImage *inImage)
{
    if (!inImage) {
        return NULL;
    }
    
    CGImageRef img = [inImage CGImage];
    CGSize size = CGSizeMake(CGImageGetWidth(img), CGImageGetHeight(img));
    
    CGContextRef cgctx = createRGBBitmapContext(img);
    
    CGRect rect = {{0,0},{size.width,size.height}};
    
    CGContextDrawImage(cgctx, rect, img);
    unsigned char *data = ( unsigned char *)CGBitmapContextGetData(cgctx);
    
    CGContextRelease(cgctx);
    return data;
}

void  ProviderReleaseData(void *info,const void *data, size_t size)
{
    free((void*)data);
}

UIImage * initImageWithPixel(void *Inpixel,uint width,uint height)
{
    if (Inpixel == NULL) {
        return nil;
    }
    
    void *imgPixel = Inpixel;
    uint w = width, h = height;
    
    uint dataLength=w*h*4;
    CGDataProviderRef provider=CGDataProviderCreateWithData(NULL, imgPixel, dataLength, ProviderReleaseData);
    
    int bitsPerComponent=8;
    int bitsPerPixel=32;
    int bytesPerRow=4*w;
    CGColorSpaceRef colorSpaceRef=CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo=kCGBitmapByteOrderDefault;
    
    CGColorRenderingIntent renderingIntent=kCGRenderingIntentDefault;
    
    CGImageRef imageRef=CGImageCreate(w, h,
                                      bitsPerComponent,
                                      bitsPerPixel,
                                      bytesPerRow,
                                      colorSpaceRef,
                                      bitmapInfo,
                                      provider, NULL, NO, renderingIntent);
    
    
    UIImage *my_Image=[UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return my_Image;
}

UIImage * initImageWithPixelNoReleaseInpixel(void *Inpixel,uint width,uint height)
{
    if (Inpixel == NULL) {
        return nil;
    }
    
    void *imgPixel = Inpixel;
    uint w = width, h = height;
    
    uint dataLength = w*h*4;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgPixel, dataLength, NULL);
    
    int bitsPerComponent=8;
    int bitsPerPixel=32;
    int bytesPerRow=4*w;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo=kCGBitmapByteOrderDefault | kCGImageAlphaLast;//kCGBitmapByteOrderDefault;
    
    CGColorRenderingIntent renderingIntent=kCGRenderingIntentDefault;
    
    CGImageRef imageRef=CGImageCreate(w, h,
                                      bitsPerComponent,
                                      bitsPerPixel,
                                      bytesPerRow,
                                      colorSpaceRef,
                                      bitmapInfo,
                                      provider, NULL, NO, renderingIntent);
    
    
    UIImage *my_Image=[UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    return my_Image;
}