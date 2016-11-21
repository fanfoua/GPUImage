//
//  RRFilterTool.h
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//


/**
 *   功能说明:
 *   工程中使用的各种辅助函数和宏定义。
 **/


/**
 * @brief 判断RGB值是否越界 [0 255]
 * @param value R,G,B值
 * @return R,G,B值 [0 255]
 */

#define QX_DEF_PADDING					10
#define QX_DEF_THRESHOLD_ZERO			1e-6
#define QX_DEF_PI_DOUBLE				3.14159265359
#define QX_DEF_FLOAT_MAX				1.175494351e+38F
#define QX_DEF_DOUBLE_MAX				1.7E+308
#define QX_DEF_FLOAT_RELATIVE_ACCURACY	2.2204e-016
#define QX_DEF_INI_MAX					2147483647
#define QX_DEF_SHORT_MAX				65535
#define QX_DEF_CHAR_MAX					255
#define	QX_DEF_SEED						42
#define QX_DEF_THRESHOLD_ZERO			1e-6
#define QX_DEF_THRESHOLD_ZERO_DOUBLE	1e-16
#define QX_DEF_ENTER					10
#define QX_DEF_BLANK					32
#define QX_DEF_STRING_LENGTH			300



enum BrightnessWarning
{
    kNoWarning,                /**< image has acceptable brightness */
    kDarkWarning,              /**< image is too dark */
    kBrightWarning            /**< image is too bright */
};

/**
 Structure to hold image statistics. Populate it with BrightnessDetection.
 */


struct imageStats
{
        
    int hist[256];      /**< Histogram of image */
    int mean;           /**< Mean value of image */
    int sum;            /**< Sum of image */
    int numPixels;      /**< Number of pixels */
    int  subSamplWidth;  /**< Subsampling rate of width in powers
                                    of 2 */
    int  subSamplHeight; /**< Subsampling rate of height in powers
                                    of 2 */
};


int pixelRange(int value);

int RGB_FloatToInt(float data,float p,float q);

double ***qx_allocd_3(int n,int r,int c);
void qx_freed_3(double ***p);
unsigned char ***qx_allocu_3(int n,int r,int c);
void qx_freeu_3(unsigned char ***p);

void qx_gradient_domain_recursive_bilateral_filter(double***out,double***in,unsigned char***texture,double sigma_spatial,double sigma_range,int h,int w,double***temp,double***temp_2w);

void qx_fuck_bilateral_filter(double***out,void *in,double sigma_spatial,double sigma_range,int h,int w,double***temp,
                              double***temp_2w);
