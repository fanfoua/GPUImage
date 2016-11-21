//
//  RRColorTransform.h
//  RROpenCV
//
//  Created by lych on 10/23/12.
//  Copyright (c) 2012 lych. All rights reserved.
//

/**
 *   功能说明:
 *   完成各种颜色空间转换。
 *  （颜色空间转换函数可优化）。
 **/

typedef struct
{
    float h;
    float s;
    float b;
}HSB;

typedef struct
{
    double  r;
    double  g;
    double  b;
}RGB;

typedef struct
{
    double  h;
    double  s;
    double  l;
}HSL;

typedef struct
{
    double  h;
    double  s;
    double  i;
}HSI;

typedef struct
{
    float Y;
    float Cb;
    float Cr;
}YCBCR;

/**
 * @brief RGB 色彩空间 转 HSL
 * @param rgb RGB色彩空间
 * @return HSL 色彩空间
 */
HSL RGBTOHSL(RGB rgb);

/**
 * @brief HSL 色彩空间 转 RGB
 * @param hsl HSL色彩空间
 * @return RGB 色彩空间
 */
RGB HSLTORGB(HSL hsl);

/**
 * @brief RGB 色彩空间 转 HSB
 * @param rgb RGB色彩空间
 * @return HSB 色彩空间
 */
HSB RGBTOHSB(RGB rgb);

/**
 * @brief HSB 色彩空间 转 RGB
 * @param hsb HSB色彩空间
 * @return RGB 色彩空间
 */
int RGB2HSB(int r,int g,int b);

/**
 * @brief HSB 色彩空间 转 RGB
 * @param hsb HSB色彩空间
 * @return RGB 色彩空间
 */
RGB HSBTORGB(HSB hsb);

/**
 * @brief RGB 色彩空间 转 HSB
 * @param rgb RGB色彩空间
 * @return HSI 色彩空间
 */
HSI RGBTOHSI(RGB rgb);

/**
 * @brief HSI 色彩空间 转 RGB
 * @param hsi HSI色彩空间
 * @return RGB 色彩空间
 */
RGB HSITORGB(HSI hsi);

/**
 * @brief RGB 色彩空间 转 YCBCR
 * @param rgb RGB色彩空间
 * @return YCBCR 色彩空间
 */
YCBCR RGBTOYCBCR(RGB rgb,int type);