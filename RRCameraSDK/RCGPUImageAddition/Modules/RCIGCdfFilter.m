//
//  RCIGCdfFilter.m
//  RRCameraSDK
//
//  Created by 淮静 on 15/4/24.
//  Copyright (c) 2015年 renn. All rights reserved.
//

#import "RCIGCdfFilter.h"
#import "RRPhotoTransform.h"

@implementation RCIGCdfFilter

//result: r - cdf, g , b - min, a - mid
int getCDFBitmap(unsigned char* src,int rows, int cols,int channels,unsigned char* dst)
{
    if (NULL == src || NULL == dst || rows <= 0 || cols <= 0) {
        return -1;
    }
    
    int coord[5][2];
    for (int i = 0; i <= 4; i++)
    {
        coord[i][0] = (int)round(rows * i / 4.0);
        coord[i][1] = (int)round(cols * i / 4.0);
    }
    
    float cdf[16][256] = {0};
    float mincdf[16] = {0};
    float midcdf[16] = {0};
    int meshrows,meshcols;
    
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
        {
            float pdf[256] = {0.0};
            
            meshcols = coord[j + 1][1] - coord[j][1];
            meshrows = coord[i + 1][0] - coord[i][0];
            
            for (int ii = coord[j][1]; ii < coord[j + 1][1]; ii++)
                for (int jj = coord[i][0]; jj < coord[i + 1][0]; jj++)
                {
                    unsigned char temp = fmax( src[(ii+jj*cols)*channels],
                                fmax( src[(ii+jj*cols)*channels+2],  src[(ii+jj*cols)*channels+1]));
                    pdf[temp] = pdf[temp] + 1.0f ;
                }
            
            int index = i * 4 + j;
            
            float clip_level = 2 / 256.0;
            float excess = 0.0;
            float excess_avg = 0.0;
            
            
            for (int k = 0; k < 256; k++)
            {
                pdf[k] /= (meshrows * meshcols);
                if (pdf[k] > clip_level) excess += (pdf[k] - clip_level);
            }
            
            excess_avg = excess / 256.0;
            for (int k = 0; k < 256; k++)
            {
                if (pdf[k] > clip_level) pdf[k] = clip_level;
                else if (pdf[k] > clip_level - excess_avg) {
                    excess -= clip_level - pdf[k];
                    pdf[k] = clip_level;
                }
                else{
                    excess -= excess_avg;
                    pdf[k] += excess_avg;
                }
            }
            excess_avg = excess / 256.0;
            
            float min = 1.0;
            for (int k = 0; k < 256; k++)
            {
                pdf[k] += excess_avg;
                if (min > pdf[k]) min = pdf[k];
            }
            mincdf[index] = min;
            
            cdf[index][0] = pdf[0];
            bool flag = true;
            for (int k = 1; k < 256; k++)
            {
                cdf[index][k] = cdf[index][k-1] +pdf[k];
                if (flag && cdf[index][k] >= 0.5)
                {
                    flag = false;
                    midcdf[index] = k/255.0;
                }
            }
        }
    
    int widthStep = 256 * 4;
    for (int i = 0; i< 16; i++) {
        for (int j = 0; j < 256; j++) {
            
            dst[i*widthStep+j*4] = (unsigned char)roundf(cdf[i][j] * 255.0);
            dst[i*widthStep+j*4+1] = 255.0;
            dst[i*widthStep+j*4+2] = (unsigned char)roundf(mincdf[i] * 255.0);
            dst[i*widthStep+j*4+3] = (unsigned char)roundf(midcdf[i] * 255.0);
        }
    }

    return 0;
}

+ (UIImage *) RCIGCdfFilter:(UIImage *) srcImage
{
    if (!srcImage) {
        return nil;
    }
    
    double time = [NSDate timeIntervalSinceReferenceDate];
    
    UIImage *image = srcImage;
    CGImageRef inImageRef = [image CGImage];
    uint width = CGImageGetWidth(inImageRef);
    uint height = CGImageGetHeight(inImageRef);
    // 获取图片像素
    unsigned char *imgPixel = RequestImagePixelsData(image);
    
    if (imgPixel == NULL) {
        return nil;
    }
    
    int rrows = 16;
    int rcols = 256;
    unsigned char *resultPixel = malloc(sizeof(unsigned char)*rrows*rcols*4);
    
    int r = getCDFBitmap(imgPixel, height, width, 4, resultPixel);
    if (r != 0) {
        NSLog(@"getCDF error!");
        free(resultPixel);
        resultPixel = NULL;
        return nil;
    }
    
    free(imgPixel);
    
    NSLog(@"God, RCIGCdfFilter time is %f",[NSDate timeIntervalSinceReferenceDate] - time);
    UIImage *resultingImage = initImageWithPixel(resultPixel, rcols, rrows);
    
    return resultingImage;
}

@end